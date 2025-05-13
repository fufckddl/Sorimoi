import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);
  // 🔔 알림 허용 다이얼로그
  void _showPermissionDialog(BuildContext context) {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '‘소리모이’에서 알림을 보내고자 합니다.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                '직교, 사운드 및 아이콘 배지가 알림에 포함될 수 있습니다.\n설정에서 이를 구성할 수 있습니다.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: const Text('허용 안 함'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: const Text('허용'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 📱 알림 UI 화면
  @override
  Widget build(BuildContext context) {
    // Route arguments에서 userId 추출
    final args = ModalRoute.of(context)!.settings.arguments;
    final int userId = args is int ? args : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/notification_sample.png', // ✅ 여기에 이미지 파일 필요
                  width: 300,
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                '알림을 켜고 매일 꾸준히 영어 학습을 이어가세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '알림을 설정하면 중요한 학습 알림만 받아볼 수 있어요.\n'
                    '꾸준한 영어 연습을 돕고 학습 루틴을 유지해 줍니다!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const Spacer(),

              // 🟣 알림 켜기 버튼 (다이얼로그)
              ElevatedButton(
                onPressed: () {
                  print("✅ 알림 켜기 버튼 눌림"); // 디버깅용 로그
                  _showPermissionDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE3D7FB),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('알림 켜기'),
              ),

              const SizedBox(height: 12),

              // ⚪ 나중에 하기 버튼
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF6F6F6),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('나중에 하기'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}