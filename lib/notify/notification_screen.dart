import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ 추가

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  // 🔔 알림 허용 다이얼로그
  Future<void> _showPermissionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '‘소리모이’에서 알림을 보내고자 합니다.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              '직교, 사운드 및 아이콘 배지가 알림에 포함될 수 있습니다.\n'
                  '설정에서 이를 구성할 수 있습니다.',
              style: TextStyle(color: Colors.grey, fontSize: 13.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(ctx).pushNamedAndRemoveUntil(
                        '/home',
                            (route) => false,
                      );
                    },
                    child: Text('허용 안 함', style: TextStyle(fontSize: 14.sp)),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      Navigator.of(ctx).pushNamedAndRemoveUntil(
                        '/home',
                            (route) => false,
                      );
                    },
                    child: Text('허용', style: TextStyle(fontSize: 14.sp)),
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
    final args = ModalRoute.of(context)!.settings.arguments;
    final int userId = args is int ? args : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.h),
              Center(
                child: Image.asset(
                  'assets/notification_sample.png',
                  width: 300.w,
                ),
              ),
              SizedBox(height: 36.h),
              Text(
                '알림을 켜고 매일 꾸준히 영어 학습을 이어가세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              Text(
                '알림을 설정하면 중요한 학습 알림만 받아볼 수 있어요.\n'
                    '꾸준한 영어 연습을 돕고 학습 루틴을 유지해 줍니다!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _showPermissionDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE3D7FB),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  textStyle: TextStyle(fontSize: 15.sp),
                ),
                child: const Text('알림 켜기'),
              ),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home',
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF6F6F6),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  textStyle: TextStyle(fontSize: 15.sp),
                ),
                child: const Text('나중에 하기'),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
