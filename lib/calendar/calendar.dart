import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mysql1/mysql1.dart';


/// 출석 달력 위젯과 DB 연동 서비스를 한 파일에 정의.

/// 출석된 날짜들을 달력에 표시하는 위젯
class AttendanceCalendar extends StatefulWidget {
  final Set<DateTime> attendanceDates;
  const AttendanceCalendar({Key? key, required this.attendanceDates}) : super(key: key);

  @override
  _AttendanceCalendarState createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<AttendanceCalendar> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  DateTime _normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  List<String> _eventsForDay(DateTime day) {
    return widget.attendanceDates.contains(_normalize(day)) ? ['attended'] : [];
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<String>(
      locale: 'ko_KR',
      firstDay: DateTime.utc(DateTime.now().year - 1, 1, 1),
      lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
      focusedDay: _focused,
      calendarFormat: _format,
      selectedDayPredicate: (day) => isSameDay(_selected, day),
      eventLoader: _eventsForDay,
      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
        markerDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
      ),
      calendarBuilders: CalendarBuilders<String>(
        defaultBuilder: (ctx, day, _) {
          bool done = widget.attendanceDates.contains(_normalize(day));
          return Container(
            margin: const EdgeInsets.all(6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? Colors.greenAccent.withOpacity(0.3) : null,
            ),
            child: Text(day.day.toString()),
          );
        },
        markerBuilder: (ctx, day, events) {
          if (events.isNotEmpty) {
            return const Positioned(
              bottom: 4,
              child: Icon(Icons.check_circle, size: 16, color: Colors.green),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      onDaySelected: (sel, foc) => setState(() { _selected = sel; _focused = foc; }),
      onFormatChanged: (fmt) => setState(() => _format = fmt),
      onPageChanged: (foc) => _focused = foc,
    );
  }
}
