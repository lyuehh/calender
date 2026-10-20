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
      match parse_int(rest[0], 9999) {
        Some(year) => @lib.print_year(year)
        None => usage()
      }
    2 =>
      match (parse_int(rest[0], 12), parse_int(rest[1], 9999)) {
        (Some(month), Some(year)) => @lib.print_month(year, month)
        _ => usage()
      }
    _ => usage()
  }
}

///|
/// Parses ASCII decimal digits, checking the bound before any overflow.
fn parse_int(s : String, maximum : Int32) -> Int32? {
  if s.length() == 0 {
    return None
  }
  let mut value = 0
  for c in s {
    if c < '0' || c > '9' {
      return None
    }
    value = value * 10 + (c.to_int() - '0'.to_int())
    if value > maximum {
      return None
    }
  }
  if value < 1 {
    None
  } else {
    Some(value)
  }
}

///|
extern "C" fn usage() -> Unit = "cal_usage"
