import 'package:flutter/material.dart';
import 'receive_qr_screen.dart';

class HomeScreen extends StatelessWidget {
  final Map user;
  final VoidCallback onPayTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onScanTap;

  const HomeScreen({
    super.key,
    required this.user,
    required this.onPayTap,
    required this.onHistoryTap,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topBar(context),
            const SizedBox(height: 28),
            _balanceCard(),
            const SizedBox(height: 36),
            _actionsGrid(context),
            const SizedBox(height: 28),
            _tipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Home",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/login");
          },
        )
      ],
    );
  }

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_rounded, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Available Balance",
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Text(
                "₹ ${user["balance"]}",
                style: const TextStyle(
                    fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      children: [
        _tile(Icons.send_rounded, "Pay", onPayTap),
        _tile(Icons.qr_code_scanner_rounded, "Scan", onScanTap),
        _tile(Icons.qr_code, "Receive", () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReceiveQrScreen(user: user),
            ),
          );
        }),
        _tile(Icons.history_rounded, "History", onHistoryTap),
      ],
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36),
            const SizedBox(height: 12),
            Text(label,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_rounded, color: Colors.greenAccent),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Your transactions are protected using AI-based fraud detection.",
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}










