from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
from db import get_cursor, conn
from models.risk_engine import calculate_risk

app = Flask(__name__)
CORS(app)

# -------------------------
# PAGE ROUTES (UI)
# -------------------------

@app.route("/")
def login_page():
    return render_template("login.html")

@app.route("/register")
def register_page():
    return render_template("register.html")

@app.route("/home")
def home_page():
    return render_template("index.html")

@app.route("/pay")
def pay_page():
    return render_template("pay.html")

@app.route("/history-page")
def history_page():
    return render_template("history.html")

# -------------------------
# API ROUTES (BACKEND)
# -------------------------

@app.route("/predict", methods=["POST"])
def predict():
    txn = request.json
    print("RECEIVED:", txn)

    risk, decision, reason = calculate_risk(txn)

    cur = get_cursor()
    cur.execute("""
        INSERT INTO transactions
        (sender, receiver, amount, country, vpn, risk_score, decision, reason)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
    """, (
        txn["sender"],
        txn["receiver"],
        txn["amount"],
        txn["country"],
        txn["vpn"],
        risk,
        decision,
        reason
    ))
    conn.commit()

    return jsonify({
        "decision": decision,
        "reason": reason
    })

@app.route("/history", methods=["GET"])
def history_api():
    cur = get_cursor()
    cur.execute("""
        SELECT sender, receiver, amount, decision, created_at
        FROM transactions
        ORDER BY created_at DESC
    """)
    rows = cur.fetchall()

    return jsonify([
        {
            "sender": r[0],
            "receiver": r[1],
            "amount": r[2],
            "decision": r[3],
            "time": str(r[4])
        }
        for r in rows
    ])

# -------------------------
# RUN
# -------------------------
if __name__ == "__main__":
    app.run(debug=True)
