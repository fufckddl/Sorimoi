import 'package:flutter/material.dart';
import 'dart:async';

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
  Timer? _fakeRecognitionTimer;

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
    _fakeRecognitionTimer?.cancel();
    super.dispose();
  }

  void toggleVoiceRecognition() {
    setState(() {
      isListening = !isListening;
      if (isListening) {
        message = "음성 인식이 시작됩니다";
        recognizedText = '';
        _controller.repeat(reverse: true);

        _fakeRecognitionTimer =
            Timer.periodic(const Duration(milliseconds: 500), (timer) {
              setState(() {
                recognizedText += '음 ';
              });
            });
      } else {
        message = "음성 인식이 끝났습니다";
        _controller.stop();
        _fakeRecognitionTimer?.cancel();
      }
    });
  }

  void togglePlayback() {
    setState(() {
      isPlaying = !isPlaying;
    });
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
                            _fakeRecognitionTimer?.cancel();
                            message = '';
                            recognizedText = '';
                            isPlaying = false;
                          });
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

            /// 🧾 음성 인식 텍스트 레이어 (아래로 이동하여 마이크 아래에 위치)
            if (recognizedText.isNotEmpty)
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

            /// 🧾 메시지 레이어 (하단 버튼 위, 그림자 제거)
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
