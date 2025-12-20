def gnn_score(txn):
    score = 0.0

    if txn.get("shared_device", False):
        score += 0.5

    if txn.get("shared_ip", False):
        score += 0.4

    return min(score, 1.0)

