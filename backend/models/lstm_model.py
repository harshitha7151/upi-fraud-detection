def lstm_score(features):
    score = 0.0

    if features["amount"] < 200:
        score += 0.3

    if features["velocity"] > 3:
        score += 0.4

    return min(score, 1.0)

