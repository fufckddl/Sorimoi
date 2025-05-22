import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class ScriptPracticeScreen extends StatefulWidget {
  const ScriptPracticeScreen({Key? key}) : super(key: key);

  @override
  State<ScriptPracticeScreen> createState() => _ScriptPracticeScreenState();
}

class _ScriptPracticeScreenState extends State<ScriptPracticeScreen> {
  static const String flaskBase = 'http://127.0.0.1:5000';
  static const String ec2Base = 'http://43.200.24.193:8000';

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? playingUrl;

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    fetchResultsWithAudio();

    if (kIsWeb) {
      html.window.onBeforeUnload.listen((event) {
        html.HttpRequest.request('$flaskBase/stop', method: 'POST');
        html.HttpRequest.request('$flaskBase/clear_text', method: 'POST');
        html.HttpRequest.request('$ec2Base/clear_text', method: 'POST');
      });
    }
  }

  Future<void> fetchResultsWithAudio() async {
    try {
      final resp = await http.get(Uri.parse('$ec2Base/result_with_audio'));
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        setState(() {
          items = data.map<Map<String, dynamic>>((e) => {
            'text': e['text'].toString().trim(),
            'filename': e['filename'],
            'score': int.tryParse(e['score'].toString()) ?? 0,
          }).toList();
        });
      } else {
        setState(() => items = []);
      }
    } catch (e) {
      setState(() => items = []);
    }
  }

  Future<void> _onPlay(String file) async {
    final url = '$ec2Base/audio/$file';

    if (playingUrl == url) {
      await _audioPlayer.pause();
      setState(() => playingUrl = null);
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        playingUrl = url;
      });
    }
  }

  Future<void> _onStop() async {
    await _audioPlayer.stop();
    setState(() {
      playingUrl = null;
    });
  }

  Color getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.amber;
    return Colors.red;
  }

  int getAverageScore() {
    if (items.isEmpty) return 0;
    final total = items.map((e) => e['score'] as int).fold(0, (a, b) => a + b);
    return (total / items.length).round();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avgScore = getAverageScore();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '평균 점수: $avgScore점',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: getScoreColor(avgScore),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: items.isNotEmpty
                    ? ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, idx) {
                    final text = items[idx]['text'];
                    final file = items[idx]['filename'];
                    final score = items[idx]['score'] ?? 0;

                    final url = '$ec2Base/audio/$file';
                    final isPlaying = (playingUrl == url);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• $text',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '점수: $score점',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: getScoreColor(score),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow),
                                onPressed: () => _onPlay(file),
                              ),
                              IconButton(
                                icon: const Icon(Icons.stop),
                                onPressed: _onStop,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                )
                    : const Center(child: Text('음성 인식 결과를 가져오는 중...')),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE0FFE0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '음성 인식 결과 및 피드백을 출력합니다.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) Navigator.pushNamed(context, '/voiceRecognition');
          if (i == 1) Navigator.pushNamed(context, '/voiceScore');
          if (i == 2) Navigator.pushNamed(context, '/voiceRecord');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: '녹음'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '기록'),
        ],
      ),
    );
  }
}
