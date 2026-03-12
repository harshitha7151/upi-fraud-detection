from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

# =====================================================
# USER MODEL
# =====================================================
class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)

    # -------- BASIC INFO --------
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)

    # -------- BANK INFO --------
    account_no = db.Column(db.String(20), unique=True, nullable=False)
    balance = db.Column(db.Float, default=50000.0)

    # -------- ROLE CONTROL --------
    # user → normal user
    # admin → admin panel access
    role = db.Column(db.String(10), default="user")

    # -------- OTP (TEMP) --------
    temp_otp = db.Column(db.Integer, nullable=True)

    # -------- TIMESTAMP --------
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<User {self.email} | Acc:{self.account_no} | Role:{self.role}>"

# =====================================================
# TRANSACTION MODEL
# =====================================================
class Transaction(db.Model):
    __tablename__ = "transactions"

    id = db.Column(db.Integer, primary_key=True)

    sender_acc = db.Column(db.String(20), nullable=False)
    receiver_acc = db.Column(db.String(20), nullable=False)

    amount = db.Column(db.Float, nullable=False)

    # Allow | Require OTP | Block
    decision = db.Column(db.String(20), nullable=False)

    risk_score = db.Column(db.Float, nullable=False)

    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<Txn {self.sender_acc} → {self.receiver_acc} ₹{self.amount} {self.decision}>"
