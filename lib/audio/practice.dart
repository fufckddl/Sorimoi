import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

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
    if (_isRecording) {
      await _stopRecordingAndSend();
    }
    if (_currentIndex < _sentences.length - 1) {
      setState(() {
        _currentIndex++;
        _recognizedText = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sentences.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final target = _sentences[_currentIndex];
    final accuracy = _calculateAccuracy(_recognizedText, target);

    return Scaffold(
      appBar: AppBar(title: const Text('발음 연습')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🎯 연습할 문장", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(target, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),

            const Text("🎙️ 인식된 문장", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _recognizedText.isEmpty ? '아직 인식된 문장이 없어요.' : _recognizedText,
                style: const TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ),

            const SizedBox(height: 20),
            Text("정확도: ${(accuracy * 100).toStringAsFixed(1)}%", style: const TextStyle(fontSize: 18)),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? "녹음 종료" : "말하기 시작"),
                  onPressed: _isRecording ? _stopRecordingAndSend : _startRecording,
                ),
                ElevatedButton(
                  onPressed: _nextSentence,
                  child: const Text("다음 문장"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
