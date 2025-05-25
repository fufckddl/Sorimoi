import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audioRecognition.dart';
import 'analyzingAudioScreen.dart'; // ✅ 추가

class ResultScreen extends StatefulWidget {
  final String audioPath;
  final String transcript;
  final int score;
  final String feedback;

  const ResultScreen({
    super.key,
    required this.audioPath,
    required this.transcript,
    required this.score,
    required this.feedback,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isUploading = false;

  double _opacity = 1.0;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _startBlinking();
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _opacity = _opacity == 1.0 ? 0.0 : 1.0;
      });
    });
  }

  Future<void> _playAudio() async {
    await _player.play(DeviceFileSource(widget.audioPath));
  }

  void _navigateToAnalyze() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalyzingFeedbackScreen(
          audioPath: widget.audioPath,
          transcript: widget.transcript,
        ),
      ),
    );
  }

  void _restartRecording() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RecogAudio()),
    );
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('결과 확인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '📝 인식된 텍스트:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.transcript,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 500),
              child: const Text(
                '버튼을 눌러 결과를 확인하세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUploading ? null : _navigateToAnalyze,
              child: Text(_isUploading ? '업로드 중...' : '당신의 발음 점수는? 💯'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _playAudio,
              icon: const Icon(Icons.play_arrow),
              label: const Text('녹음 재생'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _restartRecording,
              icon: const Icon(Icons.restart_alt),
              label: const Text('다시하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
