///|
/// A small Unix-style calendar library, ported from the Go `cal` implementation.
/// Public APIs: `today`, `month_lines`, `print_month`, `print_year`.

///|
let month_width : Int32 = 20

///|
let month_names : Array[String] = [
  "January", "February", "March", "April", "May", "June", "July", "August", "September",
  "October", "November", "December",
]

///|
/// Returns the current year, month (1-12) and day based on the system clock (UTC).
pub fn today() -> (Int32, Int32, Int32) {
  // `@env.now()` returns milliseconds since the Unix epoch (UTC).
  let ms = @env.now()
  let days = (ms / 1000UL / 86400UL).to_int()
  civil_from_days(days)
}

///|
/// Converts a count of days since 1970-01-01 into (year, month, day).
/// Algorithm from Howard Hinnant's `civil_from_days`.
fn civil_from_days(z_in : Int32) -> (Int32, Int32, Int32) {
  let z = z_in + 719468
  let era = (if z >= 0 { z } else { z - 146096 }) / 146097
  let doe = z - era * 146097
  let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365
  let y = yoe + era * 400
  let doy = doe - (365 * yoe + yoe / 4 - yoe / 100)
  let mp = (5 * doy + 2) / 153
  let d = doy - (153 * mp + 2) / 5 + 1
  let m = if mp < 10 { mp + 3 } else { mp - 9 }
  (if m <= 2 { y + 1 } else { y }, m, d)
}

///|
/// Returns the weekday of the given date, 0 = Sunday ... 6 = Saturday.
fn weekday(year : Int32, month : Int32, day : Int32) -> Int32 {
  let days = days_from_civil(year, month, day)
  // 1970-01-01 was a Thursday (weekday index 4).
  let w = (days + 4) % 7
  if w < 0 {
    w + 7
  } else {
    w
  }
}

///|
/// Converts (year, month, day) into days since 1970-01-01.
fn days_from_civil(year : Int32, month : Int32, day : Int32) -> Int32 {
  let y = if month <= 2 { year - 1 } else { year }
  let era = (if y >= 0 { y } else { y - 399 }) / 400
  let yoe = y - era * 400
  let mp = if month > 2 { month - 3 } else { month + 9 }
  let doy = (153 * mp + 2) / 5 + day - 1
  let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy
  era * 146097 + doe - 719468
}

///|
/// Returns the number of days in the given month of the given year.
fn days_in(month : Int32, year : Int32) -> Int32 {
  match month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    4 | 6 | 9 | 11 => 30
    2 => if is_leap(year) { 29 } else { 28 }
    _ => 30
  }
}

///|
fn is_leap(year : Int32) -> Bool {
  (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}

///|
/// Centers `s` within `width`, matching the Go `center` helper.
fn center(s : String, width : Int32) -> String {
  let len = s.length()
  if len >= width {
    return s
  }
  let pad = width - len
  let left = pad / 2
  repeat(" ", left) + s + repeat(" ", pad - left)
}

///|
/// Left-justifies `s` within `width`, matching the Go `padRight` helper.
fn pad_right(s : String, width : Int32) -> String {
  let len = s.length()
  if len >= width {
    return s
  }
  s + repeat(" ", width - len)
}

///|
fn repeat(s : String, n : Int32) -> String {
  let buf = StringBuilder()
  for _ in 0..<n {
    buf.write_string(s)
  }
  buf.to_string()
}

///|
/// Formats an integer right-aligned to width 2 (matching Go's "%2d").
fn pad2(n : Int32) -> String {
  if n < 10 {
    " " + n.to_string()
  } else {
    n.to_string()
  }
}

///|
/// Builds the 8 lines (header, weekday row, 6 week rows) describing one month.
pub fn month_lines(year : Int32, month : Int32) -> Array[String] {
  let lines : Array[String] = []
  let header = month_names[month - 1] + " " + year.to_string()
  lines.push(center(header, month_width))
  lines.push("Su Mo Tu We Th Fr Sa")
  let first_weekday = weekday(year, month, 1)
  let total = days_in(month, year)
  let week : Array[String] = []
  for _ in 0..<first_weekday {
    week.push("  ")
  }
  for d in 1..<=total {
    week.push(pad2(d))
    if week.length() == 7 {
      lines.push(join(week, " "))
      week.clear()
    }
  }
  if week.length() > 0 {
    while week.length() < 7 {
      week.push("  ")
    }
    lines.push(join(week, " "))
  }
  while lines.length() < 8 {
    lines.push(repeat(" ", month_width))
  }
  lines
}

///|
fn join(parts : Array[String], sep : String) -> String {
  let buf = StringBuilder()
  for i in 0..<parts.length() {
    if i > 0 {
      buf.write_string(sep)
    }
    buf.write_string(parts[i])
  }
  buf.to_string()
}

///|
/// Prints a single month to stdout.
pub fn print_month(year : Int32, month : Int32) -> Unit {
  for line in month_lines(year, month) {
    println(line)
  }
}

///|
/// Prints a whole year in a 3-column layout to stdout.
pub fn print_year(year : Int32) -> Unit {
  for quarter in [1, 4, 7, 10] {
    let m1 = month_lines(year, quarter)
    let m2 = month_lines(year, quarter + 1)
    let m3 = month_lines(year, quarter + 2)
    for i in 0..<8 {
      let left = pad_right(m1[i], month_width)
      let mid = pad_right(m2[i], month_width)
      let right = pad_right(m3[i], month_width)
      println(left + "  " + mid + "  " + right)
    }
    println("")
  }
}
