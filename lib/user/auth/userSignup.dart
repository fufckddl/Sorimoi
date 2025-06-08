import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _rePwController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController(); // ✅ 닉네임 컨트롤러 추가

  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  bool _isPasswordMatched = true;

  void _checkDuplicate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('중복 확인 기능은 아직 구현되지 않았어요.')),
    );
  }

  void _signUp() async {
    if (_pwController.text != _rePwController.text) {
      setState(() {
        _isPasswordMatched = false;
      });
      return;
    }
    setState(() {
      _isPasswordMatched = true;
    });

    final url = Uri.parse('http://43.200.24.193:5000/signup');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _idController.text.trim(),
          "password": _pwController.text.trim(),
          "name": _nameController.text.trim(),
          "phone": _phoneController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // ✅ 닉네임 SharedPreferences에 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nickname', _nicknameController.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? '가입 성공')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 오류: 가입 실패')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  Widget _buildTextField(
      String hint,
      TextEditingController controller, {
        bool obscure = false,
        Widget? suffixIcon,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
        style: ElevatedButton.styleFrom(backgroundColor: color),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                '아이디 입력 (이메일 형식)',
                _idController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요.';
                  }
                  if (!_emailRegex.hasMatch(value)) {
                    return '유효한 이메일 형식이 아닙니다.';
                  }
                  return null;
                },
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: _checkDuplicate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1EDFB),
                      minimumSize: const Size(80, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text(
                      '중복 확인',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                ),
              ),
              _buildTextField(
                '비밀번호 입력 (영문, 숫자, 특수문자 포함 8 ~ 20자)',
                _pwController,
                obscure: true,
              ),
              _buildTextField(
                '비밀번호 재입력',
                _rePwController,
                obscure: true,
              ),
              if (!_isPasswordMatched)
                const Text(
                  '비밀번호가 일치하지 않습니다.',
                  style: TextStyle(color: Colors.red),
                ),
              _buildTextField(
                '이름을 입력해주세요.',
                _nameController,
              ),
              _buildTextField(
                '닉네임을 입력해주세요.', // ✅ 닉네임 필드 추가
                _nicknameController,
              ),
              _buildTextField(
                '휴대폰번호를 입력해주세요.',
                _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _signUp();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1EDFB),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('가입하기', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Center(child: Text('OR')),
              _socialButton('카카오 계정으로 시작하기', Colors.yellow, Icons.chat),
              _socialButton('Google 계정으로 시작하기', Colors.grey, Icons.g_mobiledata),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('이미 계정이 있으신가요?'),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('로그인', style: TextStyle(color: Colors.purple)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
