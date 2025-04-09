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
  bool isPlaying = false; // ✅ 재생 상태
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
    // TODO: 실제 오디오 재생 기능과 연결 예정
  }

  void onSave() {
    Navigator.pushNamed(context, '/voiceText');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
              const SizedBox(height: 16),

              /// 📌 고정된 안내 텍스트 영역
              SizedBox(
                height: 24,
                child: Center(
                  child: Text(
                    message,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// ✍️ 실시간 인식된 텍스트
              Text(
                recognizedText,
                style:
                const TextStyle(fontSize: 14, color: Colors.black87),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              /// 🎧 재생/일시정지 버튼
              if (!isListening && recognizedText.isNotEmpty)
                Column(
                  children: [
                    const Text("녹음 다시 듣기"),
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                        size: 48,
                        color: Colors.black87,
                      ),
                      onPressed: togglePlayback,
                    ),
                  ],
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
