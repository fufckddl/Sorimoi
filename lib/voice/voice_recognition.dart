import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class CombinedVoiceScreen extends StatefulWidget {
  const CombinedVoiceScreen({Key? key}) : super(key: key);

  @override
  State<CombinedVoiceScreen> createState() => _CombinedVoiceScreenState();
}

class _CombinedVoiceScreenState extends State<CombinedVoiceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isListening = false;
  String message = '';
  String recognizedText = '';
  Color micColor = Colors.green;
  Timer? _resultTimer;
  Timer? _messageTimer;

  final String serverUrl = 'http://127.0.0.1:5000'; // 서버 주소 맞게 수정해줘

  int _selectedIndex = 1;

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
    _messageTimer?.cancel();
    super.dispose();
  }

  void showMessage(String text) {
    setState(() {
      message = text;
    });
    _messageTimer?.cancel();
    _messageTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        message = '';
      });
    });
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

  Future<String> fetchResultFromServer() async {
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
      final result = await fetchResultFromServer();
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
    });

    if (isListening) {
      await startRecognition();
      _controller.repeat(reverse: true);
      setState(() {
        recognizedText = '';
        micColor = Colors.green;
      });
      startResultPolling();
      showMessage("음성 인식이 시작됩니다");
    } else {
      await stopRecognition();
      stopResultPolling();
      _controller.stop();
      showMessage("음성 인식이 끝났습니다");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profileHome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                const SizedBox(height: 160),
                const SizedBox(height: 32),
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
                          micColor = Colors.green;
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
                      onPressed: () {
                        Navigator.pushNamed(context, '/voiceRecording');
                      },
                      child: const Text("저장!"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE3D7FB),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(150, 48),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("사용자: test123",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 100,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4F4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              recognizedText.isNotEmpty
                                  ? recognizedText
                                  : '여기에 음성 인식 결과가 표시됩니다.',
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 40,
              child: GestureDetector(
                onTap: toggleVoiceRecognition,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      width: _animation.value,
                      height: _animation.value,
                      decoration: BoxDecoration(
                        color: micColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 30),
                    );
                  },
                ),
              ),
            ),
            if (message.isNotEmpty)
              Positioned(
                top: 140,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: '연습하기'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}
