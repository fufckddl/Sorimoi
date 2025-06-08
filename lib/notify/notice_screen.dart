import 'package:flutter/material.dart';
import 'package:pj1/common/app_drawer.dart';
import 'package:pj1/common/custom_appbar.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: const CustomAppBar(
        title: '공지사항',
        showBack: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text('[공지] 소리모이 업데이트 안내 ${index + 1}'),
              subtitle: const Text('등록일: 2025.05.01'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // 추후 상세화면 이동 가능
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/voiceRecognition');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profileHome');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            label: '연습하기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
