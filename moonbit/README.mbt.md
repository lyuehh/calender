# cal — small Unix-style calendar CLI

This directory contains the MoonBit implementation, using the native C backend.
Calendar calculation and formatting are written in MoonBit. A small C adapter
provides local time-zone conversion and stderr/process-exit support.

```sh
make build
./bin/cal
./bin/cal 7 2026
./bin/cal 2026
make test
```

See the root README for the common argument, output and error contract and the
shared seven-language regression suite.
