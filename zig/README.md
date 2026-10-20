# cal — small Unix-style calendar CLI

This directory contains a Zig implementation of the lightweight `cal`-like command.

See the [shared specification](../README.md) for argument limits, error behavior
and the six-language regression suite (`make test` from the repository root).

Verified with Zig 0.17.0. A small C adapter provides local time and stdio without
depending on platform-specific `struct tm` or `FILE` layouts in Zig code.

Build:

```bash
make build
```

Run examples:

```bash
# current month
./bin/cal

# specific month
./bin/cal 7 2026

# whole year
./bin/cal 2026
```
