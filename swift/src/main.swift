import Foundation

#if canImport(Darwin)
  import Darwin
#elseif canImport(Glibc)
  import Glibc
#endif

func usage() -> Never {
  FileHandle.standardError.write(
    Data("Usage: cal [month] year  OR  cal year  OR  cal\n".utf8)
  )
  exit(2)
}

// The previous value never exceeds maximum, so accumulation cannot overflow.
func parseNumber(_ text: String, maximum: Int) -> Int {
  guard !text.isEmpty else { usage() }
  var value = 0
  for digit in text.utf8 {
    guard digit >= 48 && digit <= 57 else { usage() }
    value = value * 10 + Int(digit - 48)
    guard value <= maximum else { usage() }
  }
  guard value >= 1 else { usage() }
  return value
}

func currentYearMonth() -> (year: Int, month: Int) {
  tzset()
  var timestamp = time(nil)
  var local = tm()
  guard localtime_r(&timestamp, &local) != nil else {
    FileHandle.standardError.write(Data("cal: cannot read local date\n".utf8))
    exit(1)
  }
  return (Int(local.tm_year) + 1900, Int(local.tm_mon) + 1)
}

let arguments = Array(CommandLine.arguments.dropFirst())
let output: String
switch arguments.count {
case 0:
  let today = currentYearMonth()
  output = CalCalendar.monthOutput(year: today.year, month: today.month)
case 1:
  output = CalCalendar.yearOutput(year: parseNumber(arguments[0], maximum: 9999))
case 2:
  let month = parseNumber(arguments[0], maximum: 12)
  let year = parseNumber(arguments[1], maximum: 9999)
  output = CalCalendar.monthOutput(year: year, month: month)
default:
  usage()
}
FileHandle.standardOutput.write(Data(output.utf8))
