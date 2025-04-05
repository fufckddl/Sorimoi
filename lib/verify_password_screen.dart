import 'dart:async';
import 'package:flutter/material.dart';
import 'reset_password_screen.dart';

class VerifyPasswordScreen extends StatefulWidget {
  final String name;
  final String id;
  final String phone;

  const VerifyPasswordScreen({super.key, required this.name, required this.id, required this.phone});

  @override
  State<VerifyPasswordScreen> createState() => _VerifyPasswordScreenState();
}

class _VerifyPasswordScreenState extends State<VerifyPasswordScreen> {
  final TextEditingController _codeController = TextEditingController();
  late Timer _timer;
  int _remainingSeconds = 300;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void _onConfirmPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ResetPasswordScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("비밀번호 찾기")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: TextEditingController(text: widget.name),
              readOnly: true,
              decoration: const InputDecoration(labelText: "이름"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: widget.id),
              readOnly: true,
              decoration: const InputDecoration(labelText: "아이디"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: widget.phone),
              readOnly: true,
              decoration: const InputDecoration(labelText: "휴대폰번호"),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(hintText: "인증번호 입력"),
                  ),
                ),
                const SizedBox(width: 8),
                Text(_formatTime(_remainingSeconds)),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("인증번호를 받지 못하셨나요?"),
                    content: const Text("입력하신 정보가 올바른지 다시 확인해주세요."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("확인"),
                      ),
                    ],
                  ),
                );
              },
              child: const Text("인증번호를 받지 못하셨나요? >", style: TextStyle(color: Colors.grey)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _onConfirmPressed,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[100]),
                child: const Text("확인", style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}