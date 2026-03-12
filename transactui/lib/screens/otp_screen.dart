import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otp = TextEditingController();
  bool verifying = false;

  void verify(Map<String, dynamic> data) async {
    if (otp.text.isEmpty) return;

    setState(() => verifying = true);

    final res = await ApiService.verifyOtp({
      "sender": data["sender"],
      "receiver": data["receiver"],
      "amount": data["amount"],
      "otp": otp.text,
    });

    setState(() => verifying = false);

    // 🔥 MERGE UPDATED BALANCE INTO USER
    final updatedUser = {
      ...data["user"],
      "balance": res["new_balance"] ?? data["user"]["balance"],
    };

    // ✅ ALWAYS SEND MAP TO ResultScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ResultScreen(),
        settings: RouteSettings(
          arguments: {
            "decision": res["decision"], // "Allow" or "Block"
            "user": updatedUser,         // UPDATED USER
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text("OTP Verification")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter OTP sent to your email",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: otp,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "OTP",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: verifying ? null : () => verify(data),
                child: verifying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Verify OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    otp.dispose();
    super.dispose();
  }
}
