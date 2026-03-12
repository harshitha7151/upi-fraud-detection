import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // =========================================================
  // 🌐 SINGLE SOURCE OF BACKEND URL
  // =========================================================
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5000";
    } else if (Platform.isAndroid) {
      // ⚠️ USE YOUR LAPTOP IP (same WiFi)
      return "http://10.190.215.4:5000";
    } else {
      return "http://localhost:5000";
    }
  }

  // =========================================================
  // 🔐 LOGIN
  // =========================================================
  static Future<Map<String, dynamic>> login(
      String email, String acc, String pass) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "account_no": acc,
          "password": pass,
        }),
      );

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        return jsonDecode(res.body);
      } else {
        return {"error": "Login failed"};
      }
    } catch (e) {
      return {"error": "Server not reachable"};
    }
  }

  // =========================================================
  // 📝 REGISTER
  // =========================================================
  static Future<Map<String, dynamic>> register(
      String name, String email, String acc, String pass) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "account_no": acc,
          "password": pass,
        }),
      );

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        return jsonDecode(res.body);
      } else {
        return {"error": "Registration failed"};
      }
    } catch (e) {
      return {"error": "Server not reachable"};
    }
  }

  // =========================================================
  // 💸 PAY  ✅ FINAL FIX (OTP WILL NOT BE MASKED)
  // =========================================================
  static Future<Map<String, dynamic>> pay(Map data) async {
    try {
      data["vpn"] = data["vpn"] ?? 0;

      final res = await http.post(
        Uri.parse("$baseUrl/pay"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      // 🔥 DEBUG — VERY IMPORTANT
      print("RAW PAY STATUS => ${res.statusCode}");
      print("RAW PAY BODY => ${res.body}");

      // ❌ DO NOT OVERRIDE BACKEND RESPONSE
      if (res.body.isEmpty) {
        return {
          "decision": "Block",
          "error": "Empty response from server"
        };
      }

      return jsonDecode(res.body);
    } catch (e) {
      print("PAY API ERROR => $e");
      return {
        "decision": "Block",
        "error": "Network error"
      };
    }
  }

  // =========================================================
  // 🔑 OTP VERIFY
  // =========================================================
  static Future<Map<String, dynamic>> verifyOtp(Map data) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      print("OTP VERIFY STATUS => ${res.statusCode}");
      print("OTP VERIFY BODY => ${res.body}");

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        return jsonDecode(res.body);
      } else {
        return {"decision": "Block"};
      }
    } catch (e) {
      return {"decision": "Block"};
    }
  }

  // =========================================================
  // 📜 TRANSACTION HISTORY
  // =========================================================
  static Future<List> history(String acc) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/history/$acc"),
      );

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        return jsonDecode(res.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // =========================================================
  // 👑 ADMIN – SET USER BALANCE
  // =========================================================
  static Future<Map<String, dynamic>> setBalance(
      String acc, String bal) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/admin/set-balance"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "account_no": acc,
          "balance": bal,
        }),
      );

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        return jsonDecode(res.body);
      } else {
        return {"error": "Failed to update balance"};
      }
    } catch (e) {
      return {"error": "Server error"};
    }
  }
}
