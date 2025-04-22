import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VoiceRecognitionScreen extends StatefulWidget {
  const VoiceRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<VoiceRecognitionScreen> createState() => _VoiceRecognitionScreenState();
}

class _VoiceRecognitionScreenState extends State<VoiceRecognitionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isListening = false;
  bool isPlaying = false;
  String message = '';
  String recognizedText = '';
  Timer? _resultTimer;

  final String serverUrl = 'http://127.0.0.1:5000'; // ✅ 실제 서버 주소로 수정

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 60.0, end: 80.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _resultTimer?.cancel();
    super.dispose();
  }

  Future<void> startRecognition() async {
    try {
      final response = await http.post(Uri.parse('$serverUrl/start'));
      if (response.statusCode == 200) {
        print('🎤 인식 시작됨');
      }
    } catch (e) {
      print('❌ 인식 시작 오류: $e');
    }
  }

  Future<void> stopRecognition() async {
    try {
      final response = await http.post(Uri.parse('$serverUrl/stop'));
      if (response.statusCode == 200) {
        print('🛑 인식 종료됨');
      }
    } catch (e) {
      print('❌ 인식 종료 오류: $e');
    }
  }

  Future<String> fetchResult() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/result'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🎯 결과 받아옴: ${data['text']}');
        return data['text']?.toString() ?? '';
      }
    } catch (e) {
      print('❌ 결과 요청 오류: $e');
    }
    return '';
  }

  void startResultPolling() {
    _resultTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final result = await fetchResult();
      if (result.trim().isNotEmpty && result != recognizedText) {
        setState(() {
          recognizedText = result;
        });
      }
    });
  }

  void stopResultPolling() {
    _resultTimer?.cancel();
    _resultTimer = null;
  }

  Future<void> toggleVoiceRecognition() async {
    setState(() {
      isListening = !isListening;
      message = isListening ? "음성 인식이 시작됩니다" : "음성 인식이 끝났습니다";
    });

    if (isListening) {
      await startRecognition();
      _controller.repeat(reverse: true);
      setState(() {
        recognizedText = '';
      });
      startResultPolling();
    } else {
      await stopRecognition();
      stopResultPolling();
      _controller.stop();
    }
  }

  void onSave() {
    Navigator.pushNamed(context, '/voiceText');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  /// 🔘 마이크 버튼
                  GestureDetector(
                    onTap: toggleVoiceRecognition,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) => Container(
                        width: isListening ? _animation.value : 60.0,
                        height: isListening ? _animation.value : 60.0,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic, color: Colors.white, size: 30),
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isListening = false;
                            _controller.stop();
                            recognizedText = '';
                            message = '';
                            isPlaying = false;
                          });
                          stopResultPolling();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("다시하기"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF6F6F6),
                          foregroundColor: Colors.black,
                          minimumSize: const Size(150, 48),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onSave,
                        child: const Text("저장"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE3D7FB),
                          foregroundColor: Colors.black,
                          minimumSize: const Size(150, 48),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),

            /// 🧾 음성 인식 텍스트 레이어
            if (recognizedText.trim().isNotEmpty)
              Positioned(
                bottom: 260,
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      recognizedText,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ),
              ),

            /// 🧾 메시지 레이어
            if (message.isNotEmpty)
              Positioned(
                bottom: 170,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

