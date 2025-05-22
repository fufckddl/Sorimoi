import 'package:flutter/material.dart';
import 'audioRecognition.dart';

class NowRecordScreen extends StatelessWidget {
  const NowRecordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('실시간 분석')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: RecogAudio(),  // ✅ 클래스 이름 대문자 A로 수정됨
      ),
    );
  }
}
