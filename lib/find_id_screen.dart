import 'package:flutter/material.dart';
import 'find_id_verify_screen.dart';

class FindIdScreen extends StatefulWidget {
  const FindIdScreen({super.key});

  @override
  State<FindIdScreen> createState() => _FindIdScreenState();
}

class _FindIdScreenState extends State<FindIdScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _onSendPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FindIdVerifyScreen(
          name: _nameController.text,
          phone: _phoneController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아이디 찾기'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "회원가입 시 등록한 정보를 입력해주세요.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text("이름", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "이름을 입력해주세요",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text("휴대폰번호", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "숫자만 입력해주세요",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onSendPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[100],
                ),
                child: const Text("인증번호 발송", style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
