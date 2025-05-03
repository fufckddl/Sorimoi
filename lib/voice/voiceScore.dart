import 'package:flutter/material.dart';

class ScriptPracticeScreen extends StatelessWidget {
  const ScriptPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 샘플 텍스트
    final userText =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    final scriptText =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "SSAFY 면접 준비 - 스크립트 2",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 점수 표시
            const Text(
              '82점',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),

            // 컨트롤 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                IconButton(
                  onPressed: null,
                  icon: Icon(Icons.mic, color: Colors.black),
                ),
                IconButton(
                  onPressed: null,
                  icon: Icon(Icons.stop, color: Colors.black),
                ),
                IconButton(
                  onPressed: null,
                  icon: Icon(Icons.play_arrow, color: Colors.black),
                ),
                IconButton(
                  onPressed: null,
                  icon: Icon(Icons.refresh, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 사용자 텍스트 (핑크 박스)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFFE4E1), // 연핑크색
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                userText,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),

            // 정답 텍스트 (초록 박스)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFE0FFE0), // 연초록색
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
      bottomNavigationBar: BottomNavigationBar(onTap: (index) {
        if (index == 0) {
          Navigator.pushNamed(context, '/voiceRecognition'); // 연습하기 페이지로 이동
        } else if (index == 1) {
          Navigator.pushNamed(context, '/voiceScore'); // 피드백 페이지로 이동
        } else if (index == 2) {
          Navigator.pushNamed(context, '/voiceRecord');
        }
      },
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: '녹음',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '기록',
          ),
        ],
      ),
    );
  }
}
