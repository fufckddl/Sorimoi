import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String recognizedText = '';
  String feedbackMessage = '';
  Color micColor = Colors.green;
  Timer? _resultTimer;
  Timer? _feedbackTimer;

  final String serverUrl = 'http://127.0.0.1:5000'; // Flask
  final String ec2Url = 'http://43.200.24.193:8000'; // EC2

  String? recordedFilename;
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
    _feedbackTimer?.cancel();
    super.dispose();
  }

  Future<void> startRecognition() async {
    try {
      final now = DateTime.now();
      recordedFilename =
      'voice_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.wav';

      print('🎙️ 녹음 파일명: $recordedFilename');

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
        await uploadTextToEC2(); // 저장할 텍스트 전송만 수행
      }
    } catch (e) {
      print('❌ 인식 종료 오류: $e');
    }
  }

  Future<void> uploadTextToEC2() async {
    if (recognizedText.trim().isEmpty || recordedFilename == null) {
      print('⚠️ 텍스트 또는 파일명이 없음. 업로드 생략.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$ec2Url/upload_text'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': recognizedText,
          'filename': recordedFilename,
        }),
      );
      if (response.statusCode == 200) {
        print('✅ EC2에 텍스트 업로드 성공');
      } else {
        print('❌ EC2 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EC2 업로드 오류: $e');
    }
  }

  Future<String> fetchResultFromServer() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/result'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rawTexts = data['texts'];
        final List<String> texts = rawTexts.map((e) => e.toString()).toList();
        return texts.join('\n');
      }
    } catch (e) {
      print('❌ 결과 요청 오류: $e');
    }
    return '';
  }

  Future<String> fetchFeedbackFromServer() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/feedback'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['feedback']?.toString() ?? '';
      }
    } catch (e) {
      print('❌ 피드백 요청 오류: $e');
    }
    return '';
  }

  void startPolling() {
    _resultTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final result = await fetchResultFromServer();
      if (result.isNotEmpty && result != recognizedText) {
        setState(() {
          recognizedText = result;
        });
      }
    });

    _feedbackTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final feedback = await fetchFeedbackFromServer();
      if (feedback.isNotEmpty && feedback != feedbackMessage) {
        setState(() {
          feedbackMessage = feedback;
        });
      }
    });
  }

  void stopPolling() {
    _resultTimer?.cancel();
    _feedbackTimer?.cancel();
    _resultTimer = null;
    _feedbackTimer = null;
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
        feedbackMessage = '';
      });
      startPolling();
    } else {
      await stopRecognition();
      stopPolling();
      _controller.stop();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          isListening = false;
                          _controller.stop();
                          recognizedText = '';
                          feedbackMessage = '';
                          micColor = Colors.green;
                          recordedFilename = null;
                        });
                        stopPolling();

                        try {
                          final clearResp1 =
                          await http.post(Uri.parse('$serverUrl/clear'));
                          if (clearResp1.statusCode == 200) {
                            print('✅ Flask 서버(5000) 초기화 완료');
                          }

                          final clearResp2 = await http
                              .post(Uri.parse('$ec2Url/clear_results'));
                          if (clearResp2.statusCode == 200) {
                            print('✅ EC2 서버(8000) 초기화 완료');
                          }
                        } catch (e) {
                          print('❌ 다시하기 요청 실패: $e');
                        }
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
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
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
                              style:
                              const TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            feedbackMessage.isNotEmpty
                                ? feedbackMessage
                                : '여기에 목소리 피드백이 표시됩니다.',
                            style:
                            const TextStyle(fontSize: 14, height: 1.5),
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
                      child:
                      const Icon(Icons.mic, color: Colors.white, size: 30),
                    );
                  },
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
