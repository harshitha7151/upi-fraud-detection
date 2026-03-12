import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final String acc;
  const HistoryScreen({super.key, required this.acc});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List txns = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    txns = await ApiService.history(widget.acc);
    setState(() => loading = false);
  }

  Color statusColor(String d) {
    if (d == "Allow") return Colors.green;
    if (d == "Require OTP") return Colors.orange;
    return Colors.red;
  }

  IconData iconFor(String from) {
    return from == widget.acc
        ? Icons.arrow_upward
        : Icons.arrow_downward;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: txns.length,
              itemBuilder: (c, i) {
                final t = txns[i];
                final sent = t["from"] == widget.acc;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            sent ? Colors.red : Colors.green,
                        child: Icon(
                          iconFor(t["from"]),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sent
                                  ? "Sent to ${t["to"]}"
                                  : "Received from ${t["from"]}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Status: ${t["decision"]}",
                              style: TextStyle(
                                color: statusColor(t["decision"]),
                              ),
                            ),
                            Text(
                              "Risk Score: ${t["risk_score"]}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              t["time"],
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${sent ? "-" : "+"} ₹${t["amount"]}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              sent ? Colors.redAccent : Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}


