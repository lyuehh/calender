// Blackbox tests run against the package's public API.
// Run `moon test` to execute and `moon test --update` to refresh snapshots.

///|
test "month_lines July 2026" {
  let lines = @moonbit.month_lines(2026, 7)
  assert_eq(lines.length(), 8)
  assert_eq(lines[0], "     July 2026      ")
  assert_eq(lines[1], "Su Mo Tu We Th Fr Sa")
  // July 2026 starts on a Wednesday.
  assert_eq(lines[2], "          1  2  3  4")
  assert_eq(lines[3], " 5  6  7  8  9 10 11")
}

///|
test "month_lines February leap year 2024" {
  let lines = @moonbit.month_lines(2024, 2)
  // 2024 is a leap year: 29 days, starting on a Thursday.
  assert_eq(lines[0], "   February 2024    ")
  assert_eq(lines[2], "             1  2  3")
}
