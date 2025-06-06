import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pj1/userhome/userHome.dart';
import 'package:pj1/user/profile/profileHome.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String _recognizedText = '';
  List<String> _sentences = [];
  int _currentIndex = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSentences();
  }

  Future<void> _loadSentences() async {
    final jsonString = await rootBundle.loadString('assets/sentences.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _sentences = List<String>.from(jsonData['sentences']);
    });
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/speech.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: filePath,
    );

    setState(() {
      _isRecording = true;
      _recognizedText = '';
    });
  }

  Future<void> _stopRecordingAndSend() async {
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    if (path == null) return;

    final file = File(path);
    final uri = Uri.parse("http://43.200.24.193:5000/practice");
    final request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);
      setState(() {
        _recognizedText = data['transcript'] ?? '';
      });
    } else {
      setState(() {
        _recognizedText = '인식 실패 (코드: ${response.statusCode})';
      });
    }
  }

  double _calculateAccuracy(String spoken, String target) {
    String normalize(String text) =>
        text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();

    List<String> spokenWords = normalize(spoken).split(' ');
    List<String> targetWords = normalize(target).split(' ');

    int matched = 0;
    for (int i = 0; i < targetWords.length && i < spokenWords.length; i++) {
      if (spokenWords[i] == targetWords[i]) matched++;
    }

    return targetWords.isEmpty ? 0 : matched / targetWords.length;
  }

  void _nextSentence() async {
    if (_isRecording) await _stopRecordingAndSend();
    if (_currentIndex < _sentences.length - 1) {
      setState(() {
        _currentIndex++;
        _recognizedText = '';
      });
    }
  }

  void _previousSentence() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _recognizedText = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex == 1) return const HomeScreen();
    if (_selectedIndex == 2) return const ProfileHome();

    if (_sentences.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final target = _sentences[_currentIndex];
    final accuracy = _calculateAccuracy(_recognizedText, target);
    final progress = (_currentIndex + 1) / _sentences.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('발음 연습'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 연습할 문장
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.description, size: 18),
                      SizedBox(width: 6),
                      Text("연습할 문장", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(target, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),

            // 🎙️ 인식된 문장
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.mic, size: 18),
                      SizedBox(width: 6),
                      Text("인식된 문장", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F6ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _recognizedText.isEmpty
                          ? '아직 인식된 문장이 없어요.'
                          : _recognizedText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            // 정확도 및 진행률
            Text("정확도: ${(accuracy * 100).toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.deepPurple,
              minHeight: 8,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${_currentIndex + 1}/${_sentences.length}'),
            ),

            const Spacer(),

            // 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? "연습 종료" : "말하기 시작"),
                  onPressed: _isRecording ? _stopRecordingAndSend : _startRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _previousSentence,
                      child: const Text("이전 문장"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _nextSentence,
                      child: const Text("다음 문장"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profileHome');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.record_voice_over), label: '연습하기'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}
