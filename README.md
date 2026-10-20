# cal — seven implementations of the same calendar CLI

Implementations: Go, Rust, Dart, Crystal, Zig, MoonBit (native backend), and Swift.

```sh
make build                  # build all seven implementations
./go/bin/cal                # current month in the local time zone
./crystal/bin/cal 7 2026     # July 2026
./rust/bin/cal 2026         # whole year, three months per row
./swift/bin/cal 2 2024      # Swift implementation, including leap years
make test                   # build all seven and run the shared conformance suite
```

Each language directory also supports `make build`, `make run`, and `make fmt`.
The shared suite requires Python 3.9+ and an installed IANA time-zone database.
All seven language toolchains must be available on PATH. Zig is verified with
0.17.0; MoonBit uses its native C backend and requires a C compiler. Swift requires
Swift 6+ and is verified with Swift 6.4 on macOS; it uses Foundation and system
time APIs without third-party dependencies. See [Swift's README](swift/README.md)
for its source layout, build and formatting commands.

## Common behavior

- `cal`: current month according to the system clock and local time zone (`TZ`).
- `cal YEAR`: January through December, in four rows of three months.
- `cal MONTH YEAR`: one month, starting the week on Sunday.
- Years must be in `1..9999`, months in `1..12`. Both arguments accept only
  ASCII decimal digits; leading zeros are allowed and do not change the value.
  Signs, whitespace, separators, prefixes, flags and extra arguments are invalid.
- Dates use the proleptic Gregorian calendar, including years before 1582.
  Explicit month/year output is independent of local time zones and DST.
- Successful execution returns status `0`, writes the calendar to stdout and
  leaves stderr empty. Invalid arguments return status `2`, leave stdout empty
  and write exactly `Usage: cal [month] year  OR  cal year  OR  cal\n` to stderr.
- Month names are English. Each month has eight lines: a centered 20-character
  title, the weekday header, and six 20-character week rows (blank rows included).
  The single-month weekday header has 19 characters. Year output pads all
  columns to 20 characters, separates them with two spaces, and adds one blank
  line after each row of months. Trailing spaces are intentional.

## Verification

`python3 tests/conformance.py` checks already-built binaries without rebuilding.
Its independent reference uses Python's `calendar` module rather than treating
one of the seven implementations as necessarily correct. It compares the exact
exit status, stdout and stderr, including whitespace.

Coverage includes a complete 400-year Gregorian cycle, years 1 and 9999,
century leap-year rules, all months, leading zeros, integer overflow, malformed
and Unicode arguments, extra arguments, and DST/date-line time zones. Current
month output is checked in five time zones. MoonBit additionally has a fixed
timestamp test for local dates crossing month/year boundaries:

```sh
cd moonbit
moon test --target native
```
