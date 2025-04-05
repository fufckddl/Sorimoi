import 'dart:async';
import 'package:flutter/material.dart';

class FindIdVerifyScreen extends StatefulWidget {
  final String name;
  final String phone;

  const FindIdVerifyScreen({super.key, required this.name, required this.phone});

  @override
  State<FindIdVerifyScreen> createState() => _FindIdVerifyScreenState();
}

class _FindIdVerifyScreenState extends State<FindIdVerifyScreen> {
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("인증번호를 받지 못하셨나요?"),
        content: const Text("입력하신 이름과 휴대폰번호가 소리모이에 등록된 회원 정보와 일치하는지 확인해주세요."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  void _onConfirmPressed() {
    Navigator.pushNamed(context, '/findIdResult');
  }

  @override
  void dispose() {
    _timer.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("아이디/비밀번호 찾기"),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: '아이디 찾기'),
              Tab(text: '비밀번호 찾기'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("회원 정보로 찾기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text("회원가입 시 등록된 이름과 휴대폰번호를 입력해주세요.", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: TextEditingController(text: widget.name),
                    readOnly: true,
                    decoration: const InputDecoration(hintText: "이름을 입력해주세요."),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: widget.phone),
                          readOnly: true,
                          decoration: const InputDecoration(hintText: "휴대폰번호를 입력해주세요."),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.purple),
                        ),
                        child: const Text("재발송"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          decoration: const InputDecoration(hintText: "인증번호"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_formatTime(_remainingSeconds)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showHelpDialog,
                    child: const Text("인증번호를 받지 못하셨나요? >", style: TextStyle(color: Colors.grey)),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onConfirmPressed,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[100]),
                      child: const Text("확인", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ),
            const Center(child: Text("비밀번호 찾기 탭")),
          ],
        ),
      ),
    );
  }
}
