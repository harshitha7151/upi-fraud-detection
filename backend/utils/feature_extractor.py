def extract_features(txn):
    return {
        "amount": txn["amount"],
        "foreign": 0 if txn["country"] == "India" else 1,
        "vpn": int(txn["vpn"]),
        "velocity": txn.get("velocity", 1),
        "hour": txn.get("hour", 12)
    }
