import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'main_shell.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // ✅ Ensure context & arguments are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initVideo();
    });
  }

  void _initVideo() {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final decision = args["decision"].toString().trim();

    final videoPath = decision == "Allow"
        ? "assets/videos/success.mp4"
        : "assets/videos/failure.mp4";

    print("PLAYING VIDEO => $videoPath");

    _controller = VideoPlayerController.asset(videoPath);

    _controller.initialize().then((_) {
      if (!mounted) return;

      setState(() => _initialized = true);
      _controller.play();

      _controller.addListener(() {
        if (_controller.value.position >=
                _controller.value.duration &&
            mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => MainShell(user: args["user"]),
            ),
            (_) => false,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    if (_initialized) {
      _controller.dispose();
    }
    super.dispose();
  }
}
