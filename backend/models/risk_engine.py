from models.gnn_model import gnn_score
from models.lstm_model import lstm_score
from utils.feature_extractor import extract_features

def calculate_risk(txn):
    features = extract_features(txn)

    gnn = gnn_score(txn)
    temporal = lstm_score(features)
    device = 0.3 if txn["vpn"] else 0.1
    velocity = 0.2 if features["velocity"] > 3 else 0.05

    final_score = (
        0.4 * gnn +
        0.2 * temporal +
        0.3 * device +
        0.1 * velocity
    )

    if final_score > 0.6:
        return final_score, "BLOCKED", "High fraud probability"
    elif final_score > 0.4:
        return final_score, "OTP_REQUIRED", "Suspicious activity"
    else:
        return final_score, "APPROVED", "Low risk"
