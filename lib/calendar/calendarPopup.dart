import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 로그인 후 받은 [userId]를 전달받아 출석 시트를 열어주는 함수
Future<void> openAttendanceSheet(BuildContext context) async {

  // SharedPreferences 에서 userId 불러오기
  final prefs = await SharedPreferences.getInstance();
  final int userId = prefs.getInt('userId')!;

  Future<Set<DateTime>> fetchAttendanceDates(int userId) async {
    final url = Uri.parse('http://43.200.24.193:5000/attendance/$userId');
    final response = await http.get(url);
    print('fetchAttendanceDates called with userId: $userId');
    if (response.statusCode == 200) {
      final List<dynamic> raw = jsonDecode(response.body);
      return raw
          .map((s) => DateTime.parse(s as String))
          .map((dt) => DateTime(dt.year, dt.month, dt.day))
          .toSet();
    } else {
      throw Exception('출석 데이터를 불러올 수 없습니다: ${response.statusCode}');
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: FutureBuilder<Set<DateTime>>(
            // 하드코딩된 1 대신 전달받은 userId 사용
            future: fetchAttendanceDates(userId),
            builder: (ctx, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('에러: \${snap.error}'));
              }

              final allDates = snap.data!;
              final today = DateTime.now();
              final monthDates = allDates.where((d) => d.year == today.year && d.month == today.month).toSet();
              final totalAttended = monthDates.length;

              int consecutive = 0;
              DateTime checkDay = DateTime(today.year, today.month, today.day);
              while (allDates.contains(checkDay)) {
                consecutive++;
                checkDay = checkDay.subtract(const Duration(days: 1));
              }

              final rate = today.day > 0 ? (totalAttended / today.day * 100) : 0;

              return SingleChildScrollView(
                controller: scrollController, // <- 중요!
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // <- 핵심!
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AttendanceCalendar(attendanceDates: allDates),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statBox('이번달 출석률', '${rate.toStringAsFixed(0)}%'),
                            _statBox('총 출석일', '$totalAttended'),
                            _statBox('연속 출석일', '$consecutive'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}

Widget _statBox(String label, String value) {
  return Column(
    children: [
      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
    ],
  );
}
