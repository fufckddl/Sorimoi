import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audioRecognition.dart';

class ResultScoreScreen extends StatefulWidget {
  final String audioPath;
  final String transcript;
  final int score;
  final String feedback;

  const ResultScoreScreen({
    super.key,
    required this.audioPath,
    required this.transcript,
    required this.score,
    required this.feedback,
  });

  @override
  State<ResultScoreScreen> createState() => _ResultScoreScreenState();
}

class _ResultScoreScreenState extends State<ResultScoreScreen> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('결과 확인')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ 중요
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
            child: Column(
              children: [
                Text(
                  '💯 ${widget.score}점',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(
                  '🗣️ ${widget.feedback}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // ✅ 하단 버튼
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RecogAudio()),
                    );
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('다시하기'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('메인으로 돌아가기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
