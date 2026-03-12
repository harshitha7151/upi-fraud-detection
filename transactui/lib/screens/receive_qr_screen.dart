import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveQrScreen extends StatelessWidget {
  final Map user;
  const ReceiveQrScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // QR DATA (receiver account)
    final qrData = '{"acc":"${user["account_no"]}"}';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Receive Money"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              size: 260,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              "Ask sender to scan this QR",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "Account: ${user["account_no"]}",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

