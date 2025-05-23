//resultscreen.dart1

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'nowRecord.dart'; // ✅ 다시 음성 인식 화면으로 이동하려면 필요

class ResultScreen extends StatefulWidget {
  final String audioPath;
  final String transcript;

  const ResultScreen({super.key, required this.audioPath, required this.transcript});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isUploading = false;

  Future<void> _playAudio() async {
    await _player.play(DeviceFileSource(widget.audioPath));
  }

  Future<void> _uploadAudioFile() async {
    setState(() => _isUploading = true);

    final file = File(widget.audioPath);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('녹음 파일이 존재하지 않습니다.')),
      );
      return;
    }

    final uri = Uri.parse('http://43.200.24.193:5000/upload');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 업로드 성공')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 업로드 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 예외 발생: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
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
            const Text('📝 인식된 텍스트:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(widget.transcript, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _playAudio,
              icon: const Icon(Icons.play_arrow),
              label: const Text('녹음 재생'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadAudioFile,
              icon: const Icon(Icons.cloud_upload),
              label: Text(_isUploading ? '업로드 중...' : '서버로 업로드'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const NowRecordScreen()),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
