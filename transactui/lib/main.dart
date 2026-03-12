import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/result_screen.dart';

void main() {
  runApp(const TransactUIApp());
}

class TransactUIApp extends StatelessWidget {
  const TransactUIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        useMaterial3: true,
      ),
      initialRoute: "/login",
      routes: {
        "/login": (_) => const LoginScreen(),
        "/register": (_) => const RegisterScreen(),
        "/admin": (_) => const AdminScreen(),

        // ✅ THESE TWO WERE MISSING
        "/otp": (_) => const OtpScreen(),
        "/result": (_) => const ResultScreen(),
      },
    );
  }
}
