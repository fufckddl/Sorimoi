import 'package:flutter/material.dart';

class RecordingHomeScreen extends StatelessWidget {
  const RecordingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 40,
        leading: const SizedBox(),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.menu, color: Colors.black),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  const Text(
                    '오늘의 소리를 녹음해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SSAFY 면접 준비 - 스크립트 2',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Icon(Icons.mic, size: 48),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/voiceRecognition');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9C7F2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('시작하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('파일', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _fileCard(
                    title: 'SSAFY 면접 준비',
                    date: '2024-10-25',
                    scripts: [
                      {'name': '스크립트 1', 'score': '80.2'},
                      {'name': '스크립트 2', 'score': '87.8'},
                    ],
                  ),
                  _fileCard(
                    title: '졸업프로젝트 발표 대본',
                    date: '2024-10-25',
                    scripts: [
                      {'name': '스크립트 1', 'score': '68.7'},
                      {'name': '스크립트 2', 'score': '71.9'},
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/voiceRecognition');
          } else if (index == 1) {
            // 홈이므로 동작 없음
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profileHome'); // ✅ 프로필 탭 이동
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.record_voice_over), label: '연습하기'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }

  Widget _fileCard({
    required String title,
    required String date,
    required List<Map<String, String>> scripts,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              const Icon(Icons.chevron_left, size: 18),
              Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Icon(Icons.chevron_right, size: 18),
              const SizedBox(width: 8),
              const Icon(Icons.delete_outline, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          ...scripts.map((script) => Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 6),
            child: Row(
              children: [
                const Text('•'),
                const SizedBox(width: 4),
                Text(script['name'] ?? ''),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: double.parse(script['score']!) >= 80
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${script['score']}점',
                    style: TextStyle(
                      color: double.parse(script['score']!) >= 80
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          )),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Text('스크립트 추가하기 +', style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }
}
