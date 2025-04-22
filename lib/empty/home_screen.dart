import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 40,
        leading: const SizedBox(),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.menu, color: Colors.black),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'abce1234님, 오늘도 오셨군요!',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '오늘도 멋진 발음 연습을 시작해봐요',
              style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE7E0F3),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.mic, color: Colors.purple),
              label: const Text(
                '오늘의 소리',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['월', '화', '수', '목', '금', '토', '일']
                  .map((day) => Column(
                children: [
                  Icon(Icons.circle, size: 12, color: day == '목' ? Colors.purple : Colors.grey),
                  Text(day, style: TextStyle(fontSize: 12)),
                ],
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text('학습 기록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.article_outlined, color: Colors.black87),
                  title: Text('SSAFY 면접 준비'),
                  subtitle: Text('2024-10-25'),
                  trailing: Icon(Icons.volume_up, color: Colors.purple),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () {}, child: Text('처음')),
                TextButton(onPressed: () {}, child: Text('이전')),
                TextButton(
                  onPressed: () {},
                  child: Text('1', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                ),
                TextButton(onPressed: () {}, child: Text('2')),
                TextButton(onPressed: () {}, child: Text('3')),
                TextButton(onPressed: () {}, child: Text('다음')),
                TextButton(onPressed: () {}, child: Text('마지막')),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.record_voice_over), label: '연습하기'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
        currentIndex: 1,
        onTap: (index) {},
      ),
    );
  }
}
