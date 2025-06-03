import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'resultScoreScreen.dart';

class AnalyzingFeedbackScreen extends StatefulWidget {
  final String audioPath;
  final String transcript;

  const AnalyzingFeedbackScreen({
    super.key,
    required this.audioPath,
    required this.transcript,
  });

  @override
  State<AnalyzingFeedbackScreen> createState() => _AnalyzingFeedbackScreenState();
}

class _AnalyzingFeedbackScreenState extends State<AnalyzingFeedbackScreen> {
  double progress = 0.0;
  Timer? _timer;
  int _score = 0;
  String _feedback = '';

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    const duration = Duration(milliseconds: 100);
    int ticks = 0;

    _timer = Timer.periodic(duration, (timer) async {
      setState(() {
        progress = ticks / 50;
      });

      if (ticks >= 50) {
        timer.cancel();
        await _fetchScore();
        _navigateToResult();
      }

      ticks++;
    });
  }

  Future<void> _fetchScore() async {
    try {
      final uri = Uri.parse('http://43.200.24.193:8000/score');
      final request = http.MultipartRequest('POST', uri)
        ..fields['transcript'] = widget.transcript
        ..files.add(await http.MultipartFile.fromPath('audio', widget.audioPath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _score = data['score'] ?? 0;
        _feedback = data['feedback'] ?? '';
      } else {
        _score = 0;
        _feedback = '채점 실패 (서버 오류)';
      }
    } catch (e) {
      _score = 0;
      _feedback = '채점 중 오류 발생: $e';
    }
  }

  void _navigateToResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScoreScreen(
          audioPath: widget.audioPath,
          transcript: widget.transcript,
          score: _score,
          feedback: _feedback,
        ),
      ),
    );
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('음성 인식 결과 분석 중 ...'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 16,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFCEB9F5)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('AI가 사용자의 음성 인식 결과를 평가 중이예요 😊'),
          ],
        ),
      ),
    );
  }
}
