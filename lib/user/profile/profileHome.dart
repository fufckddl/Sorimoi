import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pj1/common/app_drawer.dart';
import 'package:pj1/common/custom_appbar.dart';

class ProfileHome extends StatefulWidget {
  const ProfileHome({super.key});

  @override
  State<ProfileHome> createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<ProfileHome> {
  String nickname = 'abcd1234';
  String userName = '';
  String phone = '';
  String email = '';
  int userId = -1;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? -1;

    // 닉네임은 유저별 키로 관리
    final nicknameKey = 'nickname_$userId';
    final nicknameLocal = prefs.getString(nicknameKey) ?? 'abcd1234';

    setState(() {
      nickname = nicknameLocal;
    });

    final url = Uri.parse('http://43.200.24.193:5000/user/profile?user_id=$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userName = data['name'] ?? '';
          phone = data['phone'] ?? '';
          email = data['email'] ?? '';
        });
      } else {
        debugPrint("❌ 프로필 조회 실패: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ 프로필 요청 에러: $e");
    }
  }

  Future<void> _saveNickname(String newNickname) async {
    final prefs = await SharedPreferences.getInstance();
    final nicknameKey = 'nickname_$userId';
    await prefs.setString(nicknameKey, newNickname);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const AppDrawer(),
      appBar: const CustomAppBar(
        title: '마이페이지',
        showBack: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/hamster.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          nickname,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showEditNicknameDialog(context),
                          child: const Icon(Icons.edit, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              _buildProfileRow('닉네임', nickname),
              _buildProfileRow('이름', userName),
              _buildProfileRow('휴대폰 번호', phone),
              _buildProfileRow('E-mail', email),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOutlinedButton(context, '로그아웃', Colors.red, () {
                    Navigator.pushReplacementNamed(context, '/userLogin');
                  }),
                  _buildOutlinedButton(context, '회원 탈퇴', Colors.red, () {
                    _showDeleteAccountDialog(context);
                  }),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/practice');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/userHome');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            label: '연습하기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildOutlinedButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: BorderSide(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color),
      ),
    );
  }

  void _showEditNicknameDialog(BuildContext context) {
    final controller = TextEditingController(text: nickname);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('닉네임 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '새 닉네임 입력'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newNickname = controller.text.trim();
              await _saveNickname(newNickname);
              setState(() {
                nickname = newNickname;
              });
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('정말 탈퇴하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('아니오'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/userLogin');
              // TODO: 회원 탈퇴 API 연결
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('예', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
