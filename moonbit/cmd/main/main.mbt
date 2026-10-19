///|
/// Entry point for the `cal` CLI.
///
/// Usage:
///   cal            # current month
///   cal 2026       # whole year
///   cal 7 2026     # specific month (month year)
fn main {
  let args = @env.args()
  // args[0] is the program name; the real arguments start at index 1.
  let rest = args[1:]
  match rest.length() {
    0 => {
      let (year, month, _) = @lib.today()
      @lib.print_month(year, month)
    }
    1 =>
      match parse_int(rest[0]) {
        Some(year) => @lib.print_year(year)
        None => usage()
      }
    2 =>
      match (parse_int(rest[0]), parse_int(rest[1])) {
        (Some(month), Some(year)) =>
          if month >= 1 && month <= 12 {
            @lib.print_month(year, month)
          } else {
            println("cal: invalid month: " + rest[0])
          }
        _ => usage()
      }
    _ => usage()
  }
}

///|
/// Parses a non-negative decimal integer, returning `None` on any invalid input.
fn parse_int(s : String) -> Int32? {
  if s.length() == 0 {
    return None
  }
  let mut value = 0
  for c in s {
    if c < '0' || c > '9' {
      return None
    }
    value = value * 10 + (c.to_int() - '0'.to_int())
  }
  Some(value)
}

///|
fn usage() -> Unit {
  println("usage: cal [[month] year]")
}
