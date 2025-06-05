import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  // 🔔 알림 허용 다이얼로그
  Future<void> _showPermissionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
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
              '직교, 사운드 및 아이콘 배지가 알림에 포함될 수 있습니다.\n'
                  '설정에서 이를 구성할 수 있습니다.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // 팝업 닫고 홈으로
                      Navigator.of(ctx).pop();
                      Navigator.of(
                        ctx,
                      ).pushNamedAndRemoveUntil('/home', (route) => false);
                    },
                    child: const Text('허용 안 함'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      // (원한다면) 여기에 알림 허용 상태 저장 예: prefs.setBool('notifAllowed', true);
                      Navigator.of(ctx).pop();
                      Navigator.of(
                        ctx,
                      ).pushNamedAndRemoveUntil('/home', (route) => false);
                    },
                    child: const Text('허용'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 📱 알림 UI 화면
  @override
  Widget build(BuildContext context) {
    // arguments 로 전달된 userId (필요 없으면 지워도 됩니다)
    final args = ModalRoute.of(context)!.settings.arguments;
    final int userId = args is int ? args : 0;

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
              child: _buildContent(context)
          ),
        )
    );
  }

  Widget _buildContent(BuildContext context) {
    // return Scaffold(
    //   backgroundColor: Colors.white,
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Image.asset(
              'assets/notification_sample.png',
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
          // const Spacer(),
          const SizedBox(height: 50,),
          ElevatedButton(
            onPressed: () => _showPermissionDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3D7FB),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('알림 켜기'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // 다이얼로그 없이 바로 홈으로
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
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
    );
    // );
  }
}
