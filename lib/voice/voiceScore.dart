// lib/screens/script_practice_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class ScriptPracticeScreen extends StatefulWidget {
  const ScriptPracticeScreen({Key? key}) : super(key: key);

  @override
  State<ScriptPracticeScreen> createState() => _ScriptPracticeScreenState();
}

class _ScriptPracticeScreenState extends State<ScriptPracticeScreen> {
  // 텍스트용 서버
  static const String textServerBase = 'http://127.0.0.1:5001';
  // 오디오용 서버
  static const String audioServerBase = 'http://43.200.24.193:5000';

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? playingUrl;

  // 텍스트+오디오 파일 리스트
  List<Map<String, String>> items = [];

  @override
  void initState() {
    super.initState();
    fetchResultsWithAudio();
  }

  Future<void> fetchResultsWithAudio() async {
    try {
      final resp = await http.get(Uri.parse('$textServerBase/result_with_audio'));
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        setState(() {
          items = data.map<Map<String, String>>((e) => {
            'text': e['text'] as String,
            'filename': e['filename'] as String,
          }).toList();
        });
      } else {
        setState(() => items = []);
      }
    } catch (e) {
      setState(() => items = []);
    }
  }

  // ▶️ 또는 ⏸️ 토글 재생
  Future<void> _onPlay(String filename) async {
    final url = '$audioServerBase/audio/$filename';
    if (playingUrl == url) {
      await _audioPlayer.stop();
      setState(() => playingUrl = null);
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() => playingUrl = url);
    }
  }

  // ⏹️ 강제 중지
  Future<void> _onStop() async {
    await _audioPlayer.stop();
    setState(() => playingUrl = null);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const Text(
              '82점',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green,
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
                    final text = items[idx]['text']!;
                    final file = items[idx]['filename']!;
                    final url = '$audioServerBase/audio/$file';
                    final isPlaying = (playingUrl == url);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '• $text',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow
                                ),
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
                    : const Center(
                  child: Text('음성 인식 결과를 가져오는 중...'),
                ),
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
