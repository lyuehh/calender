# cal — small Unix-style calendar CLI

This project implements a lightweight `cal`-like command in Go.

See the [shared specification](../README.md) for argument limits, error behavior
and the seven-language regression suite (`make test` from the repository root).

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
