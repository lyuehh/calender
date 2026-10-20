enum CalCalendar {
  static let monthWidth = 20
  static let weekHeader = "Su Mo Tu We Th Fr Sa"
  static let monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
  ]

  static func center(_ text: String, width: Int) -> String {
    let padding = max(0, width - text.utf8.count)
    let left = padding / 2
    return String(repeating: " ", count: left) + text
      + String(repeating: " ", count: padding - left)
  }

  static func padRight(_ text: String, width: Int) -> String {
    text + String(repeating: " ", count: max(0, width - text.utf8.count))
  }

  static func daysInMonth(year: Int, month: Int) -> Int {
    switch month {
    case 1, 3, 5, 7, 8, 10, 12:
      return 31
    case 4, 6, 9, 11:
      return 30
    case 2:
      let leap = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
      return leap ? 29 : 28
    default:
      preconditionFailure("invalid month")
    }
  }

  // Zeller's congruence for proleptic Gregorian years 1...9999.
  // No time zone or historical Gregorian cutover participates in the calculation.
  static func firstWeekday(year: Int, month: Int) -> Int {
    let y = month <= 2 ? year - 1 : year
    let m = month <= 2 ? month + 12 : month
    let century = y / 100
    let yearOfCentury = y % 100
    let zeller =
      (1 + 13 * (m + 1) / 5 + yearOfCentury
        + yearOfCentury / 4 + century / 4 + 5 * century) % 7
    return (zeller + 6) % 7  // 0 = Sunday, ..., 6 = Saturday.
  }

  static func monthLines(year: Int, month: Int) -> [String] {
    precondition((1...9999).contains(year) && (1...12).contains(month))
    var lines = [
      center("\(monthNames[month - 1]) \(year)", width: monthWidth),
      weekHeader,
    ]
    var week = Array(repeating: "  ", count: 7)
    var weekday = firstWeekday(year: year, month: month)
    for day in 1...daysInMonth(year: year, month: month) {
      week[weekday] = day < 10 ? " \(day)" : String(day)
      weekday += 1
      if weekday == 7 {
        lines.append(week.joined(separator: " "))
        week = Array(repeating: "  ", count: 7)
        weekday = 0
      }
    }
    if weekday != 0 {
      lines.append(week.joined(separator: " "))
    }
    while lines.count < 8 {
      lines.append(String(repeating: " ", count: monthWidth))
    }
    return lines
  }

  static func monthOutput(year: Int, month: Int) -> String {
    monthLines(year: year, month: month).joined(separator: "\n") + "\n"
  }

  static func yearOutput(year: Int) -> String {
    var lines: [String] = []
    for first in stride(from: 1, through: 10, by: 3) {
      let blocks = (first...(first + 2)).map { monthLines(year: year, month: $0) }
      for row in 0..<8 {
        lines.append(
          blocks.map { padRight($0[row], width: monthWidth) }
            .joined(separator: "  ")
        )
      }
      lines.append("")
    }
    return lines.joined(separator: "\n") + "\n"
  }
}
