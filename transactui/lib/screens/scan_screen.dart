import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  final Function(String receiverAcc) onScanned;
  const ScanScreen({super.key, required this.onScanned});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool scanned = false; // 🔐 prevents double scan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan & Pay"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (BarcodeCapture capture) {
              if (scanned) return;

              final barcode = capture.barcodes.first;
              final rawValue = barcode.rawValue;
              if (rawValue == null) return;

              try {
                // Expected QR format: {"acc":"1234567890"}
                final data = jsonDecode(rawValue);
                final receiver = data["acc"].toString();

                scanned = true;

                // 🔥 DO NOT POP HERE
                widget.onScanned(receiver);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid QR Code")),
                );
              }
            },
          ),

          // 🔳 Scan frame
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.greenAccent,
                  width: 2,
                ),
              ),
            ),
          ),

          // 🔽 Hint text
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  "Align QR within the frame",
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 6),
                Text(
                  "Scanning securely…",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



