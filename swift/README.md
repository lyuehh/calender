# cal — small Unix-style calendar CLI

This directory contains a Swift implementation of the lightweight `cal`-like command.

See the [shared specification](../README.md) for argument limits, error behavior
and the seven-language regression suite (`make test` from the repository root).

Requires Swift 6 or later. Verified with Swift 6.4 on macOS. The build uses
`swiftc` directly and has no third-party dependencies; Foundation provides
stdout/stderr access, and Darwin/Glibc provides local time-zone conversion.
Explicit dates use integer proleptic Gregorian calculations, including dates
before 1582, independently of locale, time zone and DST.

Build:

```sh
make build
```

Run examples:

```sh
# current month
./bin/cal

# specific month
./bin/cal 7 2026

# whole year
./bin/cal 2026
```

Sources are split into `src/Calendar.swift` (calendar calculation and rendering)
and `src/main.swift` (argument validation, local time and process I/O).
`make fmt` uses the toolchain's `swift format`. Compiler module caches stay in
the ignored `.build/` directory; the executable is written to `bin/cal`.
