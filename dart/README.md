# cal — small Unix-style calendar CLI

This directory contains a Dart implementation of the lightweight `cal`-like command.

See the [shared specification](../README.md) for argument limits, error behavior
and the six-language regression suite (`make test` from the repository root).

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
