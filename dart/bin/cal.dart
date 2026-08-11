import 'dart:io';

import 'package:cal/calendar.dart';

Never usage() {
  stderr.writeln('Usage: cal [month] year  OR  cal year  OR  cal');
  exit(2);
}

void main(List<String> args) {
  final out = stdout;

  switch (args.length) {
    case 0:
      final now = DateTime.now();
      printMonth(out, now.year, now.month);
    case 1:
      final year = int.tryParse(args[0]);
      if (year == null) usage();
      printYear(out, year);
    case 2:
      final month = int.tryParse(args[0]);
      final year = int.tryParse(args[1]);
      if (month == null || year == null || month < 1 || month > 12) usage();
      printMonth(out, year, month);
    default:
      usage();
  }
}
