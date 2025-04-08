import 'package:flutter/material.dart';

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
  String message = '';

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
    super.dispose();
  }

  void toggleVoiceRecognition() {
    setState(() {
      isListening = !isListening;
      if (isListening) {
        message = "음성 인식이 시작됩니다";
        _controller.repeat(reverse: true);
      } else {
        message = "음성 인식이 끝났습니다";
        _controller.stop();
      }
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
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
              Text(
                message,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isListening = false;
                        _controller.stop();
                        message = '';
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