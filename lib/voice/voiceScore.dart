import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScriptPracticeScreen extends StatefulWidget {
  const ScriptPracticeScreen({super.key});

  @override
  State<ScriptPracticeScreen> createState() => _ScriptPracticeScreenState();
}

class _ScriptPracticeScreenState extends State<ScriptPracticeScreen> {
  String scriptText = "음성 인식 결과 및 피드백을 출력합니다.";
  List<String> userTexts = [];

  @override
  void initState() {
    super.initState();
    fetchUserTexts();
  }

  Future<void> fetchUserTexts() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/result'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userTexts = List<String>.from(data['texts'] ?? []);
        });
      } else {
        setState(() {
          userTexts = ['서버 응답 오류: ${response.statusCode}'];
        });
      }
    } catch (e) {
      setState(() {
        userTexts = ['❌ 오류 발생: $e'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                IconButton(onPressed: null, icon: Icon(Icons.mic, color: Colors.black)),
                IconButton(onPressed: null, icon: Icon(Icons.stop, color: Colors.black)),
                IconButton(onPressed: null, icon: Icon(Icons.play_arrow, color: Colors.black)),
                IconButton(onPressed: null, icon: Icon(Icons.refresh, color: Colors.black)),
              ],
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
                child: userTexts.isNotEmpty
                    ? ListView.builder(
                  itemCount: userTexts.length,
                  itemBuilder: (context, index) {
                    return Text(
                      '• ${userTexts[index]}',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    );
                  },
                )
                    : const Center(child: Text('음성 인식 결과를 가져오는 중...')),
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
              child: Text(
                scriptText,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/voiceRecognition');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/voiceScore');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/voiceRecord');
          }
        },
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: '녹음'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '기록'),
        ],
      ),
    );
  }
}
