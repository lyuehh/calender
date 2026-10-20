import 'dart:io';

const int monthWidth = 20;
const String weekHeader = 'Su Mo Tu We Th Fr Sa';
const List<String> monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String center(String text, int width) {
  if (text.length >= width) return text;
  final pad = width - text.length;
  final left = pad ~/ 2;
  return ' ' * left + text + ' ' * (pad - left);
}

String padRight(String text, int width) {
  if (text.length >= width) return text;
  return text + ' ' * (width - text.length);
}

int daysInMonth(int year, int month) {
  // Day zero is the last day of the previous month. UTC avoids DST changes.
  return DateTime.utc(year, month + 1, 0).day;
}

// Returns weekday of the first day of the month, 0 = Sunday .. 6 = Saturday.
int firstWeekday(int year, int month) {
  // DateTime.weekday: Monday=1 .. Sunday=7.
  return DateTime.utc(year, month, 1).weekday % 7;
}

List<String> monthLines(int year, int month) {
  final lines = <String>[];
  lines.add(center('${monthNames[month - 1]} $year', monthWidth));
  lines.add(weekHeader);

  final start = firstWeekday(year, month);
  final total = daysInMonth(year, month);

  final week = <String>[];
  for (var i = 0; i < start; i++) {
    week.add('  ');
  }
  for (var day = 1; day <= total; day++) {
    week.add(day.toString().padLeft(2));
    if (week.length == 7) {
      lines.add(week.join(' '));
      week.clear();
    }
  }
  if (week.isNotEmpty) {
    while (week.length < 7) {
      week.add('  ');
    }
    lines.add(week.join(' '));
  }

  while (lines.length < 8) {
    lines.add(' ' * monthWidth);
  }

  return lines;
}

void printMonth(IOSink out, int year, int month) {
  for (final line in monthLines(year, month)) {
    out.writeln(line);
  }
}

void printYear(IOSink out, int year) {
  for (var quarter = 1; quarter <= 12; quarter += 3) {
    final m1 = monthLines(year, quarter);
    final m2 = monthLines(year, quarter + 1);
    final m3 = monthLines(year, quarter + 2);

    for (var i = 0; i < 8; i++) {
      final left = padRight(m1[i], monthWidth);
      final mid = padRight(m2[i], monthWidth);
      final right = padRight(m3[i], monthWidth);
      out.writeln('$left  $mid  $right');
    }
    out.writeln();
  }
}
