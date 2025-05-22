//아영 더보기 화면 추가
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 240,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(top: 100, left: 20),
            children: [
              ListTile(
                title: const Text("나의정보", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/profileHome');
                },
              ),
              ListTile(
                title: const Text("공지사항", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/notice');
                },
              ),
              ListTile(
                title: const Text("고객센터", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/support');
                },
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, size: 28),
            ),
          ),
          const Positioned(
            top: 16,
            left: 20,
            child: Icon(Icons.notifications, size: 24),
          ),
        ],
      ),
    );
  }
}
