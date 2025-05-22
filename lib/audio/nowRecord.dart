//nowrecord.dart

import 'package:flutter/material.dart';
import 'audioRecognition.dart';

class NowRecordScreen extends StatelessWidget {
  const NowRecordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('정말 나가시겠어요?'),
            content: const Text('현재 녹음 중일 시 데이터가 손실될 수 있습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('나가기'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('실시간 분석')),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: RecogAudio(),
        ),
      ),
    );
  }
}
