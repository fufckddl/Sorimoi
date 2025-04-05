// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:pj1/main.dart'; // ← 여기가 중요해

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // 앱 실행
    await tester.pumpWidget(const SoriMoiApp());

    // 시작 값 확인
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // + 버튼 클릭
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // 증가 후 값 확인
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}