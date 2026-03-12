from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_mail import Mail, Message

import joblib
import numpy as np
import tensorflow as tf
import random
from datetime import datetime

# =====================================================
# APP SETUP
# =====================================================
app = Flask(__name__)
CORS(app)

@app.after_request
def after_request(response):
    response.headers.add("Access-Control-Allow-Origin", "*")
    response.headers.add("Access-Control-Allow-Headers", "Content-Type,Authorization")
    response.headers.add("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS")
    return response

# =====================================================
# DATABASE CONFIG
# =====================================================
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///database.db"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

# =====================================================
# MAIL CONFIG
# =====================================================
app.config.update(
    MAIL_SERVER="smtp.gmail.com",
    MAIL_PORT=587,
    MAIL_USE_TLS=True,
    MAIL_USERNAME="transactflow230@gmail.com",
    MAIL_PASSWORD="iiazghtkocwzahkl",   # Gmail App Password
    MAIL_DEFAULT_SENDER="transactflow230@gmail.com"
)

db = SQLAlchemy(app)
mail = Mail(app)

# =====================================================
# DATABASE MODELS
# =====================================================
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    email = db.Column(db.String(120), unique=True)
    password = db.Column(db.String(100))
    account_no = db.Column(db.String(20), unique=True)
    balance = db.Column(db.Float, default=50000.0)
    role = db.Column(db.String(10), default="user")
    temp_otp = db.Column(db.Integer, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


class Transaction(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    sender_acc = db.Column(db.String(20))
    receiver_acc = db.Column(db.String(20))
    amount = db.Column(db.Float)
    decision = db.Column(db.String(20))
    risk_score = db.Column(db.Float)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)


with app.app_context():
    db.create_all()

# =====================================================
# LOAD ML MODELS
# =====================================================
baseline_model = joblib.load("fraud_model.pkl")
features = joblib.load("features.pkl")
lstm_model = tf.keras.models.load_model("lstm_model.h5")

# =====================================================
# REGISTER
# =====================================================
@app.route("/register", methods=["POST"])
def register():
    d = request.json
    if User.query.filter_by(account_no=d["account_no"]).first():
        return jsonify({"error": "Account exists"}), 400

    user = User(
        name=d["name"],
        email=d["email"],
        password=d["password"],
        account_no=d["account_no"]
    )
    db.session.add(user)
    db.session.commit()
    return jsonify({"message": "Registered successfully"})

# =====================================================
# LOGIN
# =====================================================
@app.route("/login", methods=["POST"])
def login():
    d = request.json
    user = User.query.filter_by(email=d["email"]).first()

    if not user or user.password != d["password"]:
        return jsonify({"error": "Invalid credentials"}), 401

    return jsonify({
        "id": user.id,
        "name": user.name,
        "email": user.email,
        "account_no": user.account_no,
        "balance": user.balance,
        "role": user.role
    })

# =====================================================
# PAY (OTP > VPN RULE > ML)
# =====================================================
@app.route("/pay", methods=["POST"])
def pay():
    d = request.json
    print("PAY REQUEST =>", d)

    sender = User.query.get(int(d["sender"]))
    receiver = User.query.filter_by(account_no=str(d["receiver"])).first()
    amount = float(d["amount"])
    vpn_flag = int(d.get("vpn", 0))

    if not sender or not receiver:
        return jsonify({"decision": "Block"})

    # 🚫 VPN ABUSE RULE
    if vpn_flag == 1 and 3000 <= amount < 5000:
        txn = Transaction(
            sender_acc=sender.account_no,
            receiver_acc=receiver.account_no,
            amount=amount,
            decision="Block",
            risk_score=0.9
        )
        db.session.add(txn)
        db.session.commit()
        return jsonify({"decision": "Block"})

    # 🔐 OTP FOR HIGH AMOUNT (OVERRIDES EVERYTHING)
    if amount >= 5000:
        sender.temp_otp = random.randint(100000, 999999)

        txn = Transaction(
            sender_acc=sender.account_no,
            receiver_acc=receiver.account_no,
            amount=amount,
            decision="Require OTP",
            risk_score=0.5
        )
        db.session.add(txn)
        db.session.commit()

        try:
            mail.send(Message(
                subject="TransactFlow OTP Verification",
                recipients=[sender.email],
                body=f"Your OTP is {sender.temp_otp}"
            ))
        except Exception as e:
            print("MAIL ERROR =>", e)

        return jsonify({"decision": "Require OTP"})

    # 🤖 ML — ONLY FOR SMALL TXNS (< 3000)
    base = baseline_model.predict_proba(
        np.array([[d.get(f, 0) for f in features]])
    )[0][1]

    temporal = lstm_model.predict(
        np.array(d["sequence"]).reshape(1, 5, 1),
        verbose=0
    )[0][0]

    risk_score = round(0.6 * base + 0.4 * temporal, 3)

    if amount < 3000 and risk_score > 0.7:
        txn = Transaction(
            sender_acc=sender.account_no,
            receiver_acc=receiver.account_no,
            amount=amount,
            decision="Block",
            risk_score=risk_score
        )
        db.session.add(txn)
        db.session.commit()
        return jsonify({"decision": "Block"})

    # ✅ ALLOW
    sender.balance -= amount
    receiver.balance += amount

    txn = Transaction(
        sender_acc=sender.account_no,
        receiver_acc=receiver.account_no,
        amount=amount,
        decision="Allow",
        risk_score=risk_score
    )
    db.session.add(txn)
    db.session.commit()

    return jsonify({
        "decision": "Allow",
        "new_balance": sender.balance,
        "risk_score": risk_score
    })

# =====================================================
# OTP VERIFY
# =====================================================
@app.route("/verify-otp", methods=["POST"])
def verify_otp():
    d = request.json

    sender = User.query.get(int(d["sender"]))
    receiver = User.query.filter_by(account_no=str(d["receiver"])).first()
    amount = float(d["amount"])

    if not sender or not receiver:
        return jsonify({"decision": "Block"})

    if sender.temp_otp != int(d["otp"]):
        return jsonify({"decision": "Block"})

    sender.temp_otp = None
    sender.balance -= amount
    receiver.balance += amount

    txn = Transaction(
        sender_acc=sender.account_no,
        receiver_acc=receiver.account_no,
        amount=amount,
        decision="Allow",
        risk_score=0.4
    )
    db.session.add(txn)
    db.session.commit()

    return jsonify({
        "decision": "Allow",
        "new_balance": sender.balance
    })

# =====================================================
# HISTORY
# =====================================================
@app.route("/history/<account_no>")
def history(account_no):
    txns = Transaction.query.filter(
        (Transaction.sender_acc == account_no) |
        (Transaction.receiver_acc == account_no)
    ).order_by(Transaction.timestamp.desc()).all()

    return jsonify([{
        "from": t.sender_acc,
        "to": t.receiver_acc,
        "amount": t.amount,
        "decision": t.decision,
        "risk_score": t.risk_score,
        "time": t.timestamp.strftime("%Y-%m-%d %H:%M:%S")
    } for t in txns])

# =====================================================
# RUN
# =====================================================
if __name__ == "__main__":
    print("🚀 TransactFlow Backend Running (FINAL LOGIC)")
    app.run(host="0.0.0.0", port=5000, debug=True, use_reloader=False)
