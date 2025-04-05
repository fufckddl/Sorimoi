import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  void _onResetPressed() {
    if (_newPwController.text != _confirmPwController.text) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("오류"),
          content: const Text("비밀번호가 일치하지 않습니다."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("확인"),
            ),
          ],
        ),
      );
      return;
    }

    // TODO: 실제 비밀번호 변경 처리 로직 추가

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("비밀번호 변경 완료"),
        content: const Text("새로운 비밀번호로 다시 로그인해주세요."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/start', (route) => false);
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("비밀번호 재설정")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("새 비밀번호", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _newPwController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "새 비밀번호를 입력해주세요",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text("새 비밀번호 확인", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPwController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "한 번 더 입력해주세요",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _onResetPressed,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[100]),
                child: const Text("비밀번호 재설정", style: TextStyle(color: Colors.black)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
