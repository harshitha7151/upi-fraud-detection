import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = TextEditingController();
    final bal = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, "/login"),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: acc, decoration: const InputDecoration(labelText: "Account Number")),
            TextField(controller: bal, decoration: const InputDecoration(labelText: "New Balance")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await ApiService.setBalance(acc.text, bal.text);
              },
              child: const Text("Update Balance"),
            )
          ],
        ),
      ),
    );
  }
}
