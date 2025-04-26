import 'package:flutter/material.dart';
import 'dart:async';

class AnalyzingFeedbackScreen extends StatefulWidget {
  const AnalyzingFeedbackScreen({super.key});

  @override
  State<AnalyzingFeedbackScreen> createState() => _AnalyzingFeedbackScreenState();
}

class _AnalyzingFeedbackScreenState extends State<AnalyzingFeedbackScreen> {
  double progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    const duration = Duration(milliseconds: 100);
    int ticks = 0;
    _timer = Timer.periodic(duration, (timer) {
      setState(() {
        progress = ticks / 50;
      });
      if (ticks >= 50) {
        timer.cancel();

        // ✅ 분석 완료 후 화면 이동
        Navigator.pushReplacementNamed(context, '/scriptPractice');
      }
      ticks++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('텍스트로 변환한 음성을 분석중이에요 !',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('잠시만 기다려주세요', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 16,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation(Color(0xFFCEB9F5)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('피드백 생성 중,,,'),
        ],
      ),
    );
  }
}
