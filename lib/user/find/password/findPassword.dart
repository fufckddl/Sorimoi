import 'package:flutter/material.dart';

class FindPasswordScreen extends StatefulWidget {
  const FindPasswordScreen({super.key});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _onSendPressed() {
    // 인증번호 발송 후 다음 화면으로 이동 (실제 로직 구현 필요)
    Navigator.pushNamed(context, '/verifyPassword');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("아이디/비밀번호 찾기")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("본인인증", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("등록된 회원정보 확인을 통해 비밀번호를 재설정 하실 수 있습니다.",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "이름을 입력해주세요.",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                hintText: "아이디를 입력해주세요.",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "휴대폰번호를 입력해주세요.",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _onSendPressed,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[100]),
                child: const Text("인증번호 발송", style: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("아이디가 기억나지 않는다면?"),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/findId'),
                  child: const Text("아이디 찾기", style: TextStyle(color: Colors.purple)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
