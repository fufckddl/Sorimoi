import 'package:flutter/material.dart';
import 'find_id_screen.dart';
import 'find_password_screen.dart';

class FindAccountTabScreen extends StatelessWidget {
  const FindAccountTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("아이디/비밀번호 찾기"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "아이디 찾기"),
              Tab(text: "비밀번호 찾기"),
            ],
            indicatorColor: Colors.purple,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: const TabBarView(
          children: [
            FindIdScreen(),
            FindPasswordScreen(),
          ],
        ),
      ),
    );
  }
}
