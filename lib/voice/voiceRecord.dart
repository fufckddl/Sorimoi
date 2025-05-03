import 'package:flutter/material.dart';

class VoiceRecordScreen extends StatelessWidget {
  const VoiceRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 기록'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildCategory('SSAFY 연전 준비', [
            buildRecordItem('스크립트 1', '완료', '2024-10-25'),
            buildRecordItem('스크립트 2', '진행중', '2024-10-25'),
          ]),
          const SizedBox(height: 16),
          buildCategory('졸업프로젝트 발표 대본', [
            buildRecordItem('스크립트 1', '실패', '2024-10-25'),
            buildRecordItem('스크립트 2', '완료', '2024-10-25'),
          ]),
          const SizedBox(height: 16),
          buildCategory('연휴 대본', [
            buildRecordItem('스크립트 1', '진행중', '2024-10-25'),
            buildRecordItem('스크립트 2', '완료', '2024-10-25'),
          ]),
          const SizedBox(height: 24),
          Center(child: buildPagination()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/voiceRecognition');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/voiceRecord');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profileHome');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: '연습하기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }

  Widget buildCategory(String title, List<Widget> records) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 16),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.expand_more),
              ],
            ),
            const SizedBox(height: 12),
            ...records,
          ],
        ),
      ),
    );
  }

  Widget buildRecordItem(String name, String status, String date) {
    Color statusColor;
    switch (status) {
      case '완료':
        statusColor = Colors.green;
        break;
      case '실패':
        statusColor = Colors.red;
        break;
      case '진행중':
        statusColor = Colors.purple;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 16),
          const SizedBox(width: 8),
          Text(name),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Text(date, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          const Icon(Icons.star_border, size: 16),
        ],
      ),
    );
  }

  Widget buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(onPressed: () {}, child: const Text('처음')),
        TextButton(onPressed: () {}, child: const Text('이전')),
        const Text('1', style: TextStyle(fontWeight: FontWeight.bold)),
        TextButton(onPressed: () {}, child: const Text('2')),
        TextButton(onPressed: () {}, child: const Text('3')),
        TextButton(onPressed: () {}, child: const Text('다음')),
        TextButton(onPressed: () {}, child: const Text('마지막')),
      ],
    );
  }
}
