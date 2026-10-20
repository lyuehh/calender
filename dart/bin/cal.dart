import 'dart:io';

import 'package:cal/calendar.dart';

Never usage() {
  stderr.writeln('Usage: cal [month] year  OR  cal year  OR  cal');
  exit(2);
}

int parseNumber(String text, int maximum) {
  if (text.isEmpty) usage();
  var value = 0;
  for (final digit in text.codeUnits) {
    if (digit < 48 || digit > 57) usage();
    value = value * 10 + digit - 48;
    if (value > maximum) usage();
  }
  if (value < 1) usage();
  return value;
}

void main(List<String> args) {
  final out = stdout;

  switch (args.length) {
    case 0:
      final now = DateTime.now();
      printMonth(out, now.year, now.month);
    case 1:
      final year = parseNumber(args[0], 9999);
      printYear(out, year);
    case 2:
      final month = parseNumber(args[0], 12);
      final year = parseNumber(args[1], 9999);
      printMonth(out, year, month);
    default:
      usage();
  }
}
