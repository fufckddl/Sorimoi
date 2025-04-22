import 'package:flutter/material.dart';

class FindIdResultScreen extends StatelessWidget {
  final String foundId;

  const FindIdResultScreen({super.key, required this.foundId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("아이디/비밀번호 찾기"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Center(
              child: Text(
                "아이디 찾기 결과",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "회원님의 휴대전화로\n가입된 아이디가 있습니다.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: foundId),
              decoration: const InputDecoration(
                labelText: '아이디',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("비밀번호가 기억나지 않는다면?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/findPassword');
                  },
                  child: const Text("비밀번호 찾기", style: TextStyle(color: Colors.purple)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/start',
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[100],
                ),
                child: const Text("로그인", style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}