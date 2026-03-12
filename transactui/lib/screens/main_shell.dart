import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'pay_screen.dart';
import 'history_screen.dart';
import 'scan_screen.dart';

class MainShell extends StatefulWidget {
  final Map user;
  const MainShell({super.key, required this.user});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  String? scannedReceiver;

  void openPay([String? receiver]) {
    setState(() {
      scannedReceiver = receiver;
      index = 1; // 🔁 switch to Pay tab
    });
  }

  void openScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanScreen(
          onScanned: (receiver) {
            Navigator.pop(context); // ✅ close scanner
            openPay(receiver);      // ✅ open Pay tab
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          HomeScreen(
            user: widget.user,
            onPayTap: () => openPay(),
            onHistoryTap: () => setState(() => index = 2),
            onScanTap: () => openScanner(context),
          ),

          PayScreen(
            user: widget.user,
            prefillReceiver: scannedReceiver,
          ),

          HistoryScreen(acc: widget.user["account_no"]),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send_rounded),
            label: "Pay",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: "History",
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => openScanner(context),
        child: const Icon(Icons.qr_code_scanner_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}


