import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _rePwController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _checkDuplicate() {
    // TODO: 아이디 중복 확인 로직
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('중복 확인 기능은 아직 구현되지 않았어요.')),
    );
  }

  void _signUp() {
    // TODO: 가입 처리 로직
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('가입이 완료되었습니다!')),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool obscure = false, Widget? suffix}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
          suffix: suffix,
        ),
      ),
    );
  }

  Widget _socialButton(String label, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: double.infinity,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: Colors.black),
        label: Text(label, style: const TextStyle(color: Colors.black)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              '아이디 입력 (6 ~ 20자)',
              _idController,
              suffix: ElevatedButton(
                onPressed: _checkDuplicate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1EDFB),
                  minimumSize: const Size(80, 36),
                ),
                child: const Text('중복 확인', style: TextStyle(color: Colors.black)),
              ),
            ),
            _buildTextField(
              '비밀번호 입력 (영문, 숫자, 특수문자 포함 8 ~ 20자)',
              _pwController,
              obscure: true,
            ),
            _buildTextField('비밀번호 재입력', _rePwController, obscure: true),
            _buildTextField('이름을 입력해주세요.', _nameController),
            _buildTextField('휴대폰번호를 입력해주세요.', _phoneController),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1EDFB),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('가입 하기', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Center(child: Text('OR')),
            _socialButton('카카오 연결하기', Colors.yellow, Icons.chat),
            _socialButton('Google 연결하기', Colors.grey.shade300, Icons.g_mobiledata),
            _socialButton('이메일 연결하기', Colors.lightBlue.shade200, Icons.email),
            _socialButton('Apple 연결하기', Colors.black, Icons.apple),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('이미 계정이 있으신가요?'),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 로그인 화면으로 돌아가기
                  },
                  child: const Text(
                    '로그인하세요',
                    style: TextStyle(color: Colors.purple),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}