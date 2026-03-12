import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';
import 'result_screen.dart';
import 'otp_screen.dart';

class PayScreen extends StatefulWidget {
  final Map user;
  final String? prefillReceiver;

  const PayScreen({
    super.key,
    required this.user,
    this.prefillReceiver,
  });

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final receiver = TextEditingController();
  final amount = TextEditingController();

  late VideoPlayerController loading;
  bool processing = false;
  bool initialized = false;

  @override
  void initState() {
    super.initState();

    if (widget.prefillReceiver != null &&
        widget.prefillReceiver!.isNotEmpty) {
      receiver.text = widget.prefillReceiver!;
    }

    loading = VideoPlayerController.asset("assets/videos/loading.mp4");
    loading.initialize().then((_) {
      loading.setLooping(true);
      if (mounted) setState(() => initialized = true);
    });
  }

  // =====================================================
  // 💸 PAY FUNCTION (ANDROID SAFE)
  // =====================================================
  Future<void> pay() async {
    if (receiver.text.isEmpty || amount.text.isEmpty) return;
    if (processing || !initialized) return;

    setState(() => processing = true);
    loading.play();

    final res = await ApiService.pay({
      "sender": widget.user["id"],
      "receiver": receiver.text.trim(),
      "amount": double.parse(amount.text),
      "sequence": [10, 20, 15, 18, double.parse(amount.text)],
      "vpn": 1, // 🔥 VPN ON (for demo/testing)
    });

    loading.pause();
    loading.seekTo(Duration.zero);

    if (!mounted) return;

    // 🔥 IMPORTANT: REMOVE OVERLAY FIRST
    setState(() => processing = false);

    // 🔥 ANDROID FIX: WAIT FOR UI TO SETTLE
    await Future.delayed(const Duration(milliseconds: 300));

    print("PAY RESPONSE => $res");

    final decision = res["decision"]?.toString().trim() ?? "Block";

    // =====================================================
    // 🔐 OTP FLOW (HIGHEST PRIORITY)
    // =====================================================
    if (decision.contains("OTP")) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const OtpScreen(),
          settings: RouteSettings(
            arguments: {
              "sender": widget.user["id"],
              "receiver": receiver.text.trim(),
              "amount": double.parse(amount.text),
              "user": widget.user,
            },
          ),
        ),
      );
      return;
    }

    // =====================================================
    // ❌ BLOCK FLOW
    // =====================================================
    if (decision == "Block") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ResultScreen(),
          settings: RouteSettings(
            arguments: {
              "decision": "Block",
              "user": widget.user,
            },
          ),
        ),
      );
      return;
    }

    // =====================================================
    // ✅ ALLOW FLOW
    // =====================================================
    if (res.containsKey("new_balance")) {
      widget.user["balance"] = res["new_balance"];
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ResultScreen(),
        settings: RouteSettings(
          arguments: {
            "decision": "Allow",
            "user": widget.user,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pay"), centerTitle: true),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _receiverCard(),
                const SizedBox(height: 22),
                _amountCard(),
                const Spacer(),
                _payButton(),
              ],
            ),
          ),

          // 🔒 LOADING OVERLAY
          if (processing && initialized)
            Container(
              color: Colors.black54,
              child: Center(
                child: AspectRatio(
                  aspectRatio: loading.value.aspectRatio,
                  child: VideoPlayer(loading),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _receiverCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pay To",
            style: TextStyle(fontSize: 14, color: Colors.white60),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: receiver,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Receiver Account Number",
              prefixIcon: Icon(Icons.person_outline),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Amount",
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: amount,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              hintText: "₹ 0",
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _payButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: pay,
        child: const Text("Pay Securely"),
      ),
    );
  }

  @override
  void dispose() {
    loading.dispose();
    receiver.dispose();
    amount.dispose();
    super.dispose();
  }
}
