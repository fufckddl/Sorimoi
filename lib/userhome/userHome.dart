import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pj1/calendar/calendarPopup.dart';
import 'package:pj1/user/auth/userLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _userId;
  String? _userName;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    print('🔍 loaded userId from prefs: $id');
    final nickname = prefs.getString('userName');
    setState(() {
      _userId = id;
      _userName = nickname;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      //이부분
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // 아직 userId를 불러오는 중이면 로딩 표시
    if (_userId == null) {
      return StartScreen();
    }
    // — 여기에 id값 콘솔에 출력 —
    print('🔍 build() → current userId: $_userId');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 40,
        leading: const SizedBox(),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.menu, color: Colors.black),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.purple),
                  const SizedBox(width: 6),
                  Text(
                    "${_userName!}님, 오늘도 오셨군요!",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.star, size: 18, color: Colors.purple),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                "오늘도 멋진 발음 연습을 시작해봐요",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Text("음성 녹음 바로가기", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Spacer(),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black45),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/recording');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9C7F2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.mic, size: 18, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            '오늘의 소리',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("출석 체크", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['월', '화', '수', '목', '금', '토']
                  .map((day) => GestureDetector(
                onTap: () {
                  openAttendanceSheet(context);
                },
                child: Column(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ['화', '수', '목'].contains(day)
                            ? Colors.purple
                            : Colors.white,
                        border: Border.all(
                          color: ['화', '수', '목'].contains(day)
                              ? Colors.purple
                              : Colors.grey,
                        ),
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(day, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text("학습 기록", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _recordCard("2025-04-22 녹음", "87", Colors.green, "2025-04-22"),
                ],
              ),
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pageButton('처음'),
                  _pageButton('이전'),
                  _pageButton('1', active: true),
                  _pageButton('2'),
                  _pageButton('3'),
                  _pageButton('다음'),
                  _pageButton('마지막'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/voice');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profileHome');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.record_voice_over), label: '연습하기'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }

  static Widget _recordCard(String title, String score, Color color, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "$score 점",
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.purple),
        ],
      ),
    );
  }

  static Widget _pageButton(String text, {bool active = false}) {
    return TextButton(
      onPressed: () {},
      child: Text(
        text,
        style: TextStyle(
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? Colors.red : Colors.black,
        ),
      ),
    );
  }
}