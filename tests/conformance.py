#!/usr/bin/env python3
"""Compare all six CLIs to Python's independent proleptic Gregorian calendar."""

import calendar
from datetime import datetime
import difflib
import os
from pathlib import Path
import subprocess
import sys
from zoneinfo import ZoneInfo


ROOT = Path(__file__).resolve().parents[1]
LANGUAGES = ("go", "rust", "dart", "crystal", "zig", "moonbit")
MONTH_NAMES = (
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
)
USAGE = b"Usage: cal [month] year  OR  cal year  OR  cal\n"
CALENDAR = calendar.Calendar(firstweekday=6)


def month_lines(year, month):
    title = f"{MONTH_NAMES[month - 1]} {year}"
    left = (20 - len(title)) // 2
    lines = [" " * left + title + " " * (20 - left - len(title)),
             "Su Mo Tu We Th Fr Sa"]
    for week in CALENDAR.monthdayscalendar(year, month):
        lines.append(" ".join(f"{day:2}" if day else "  " for day in week))
    lines.extend([" " * 20] * (8 - len(lines)))
    return lines


def expected_month(year, month):
    return ("\n".join(month_lines(year, month)) + "\n").encode("ascii")


def expected_year(year):
    lines = []
    for first in (1, 4, 7, 10):
        blocks = [month_lines(year, month) for month in range(first, first + 3)]
        lines.extend("  ".join(row.ljust(20) for row in rows) for rows in zip(*blocks))
        lines.append("")
    return ("\n".join(lines) + "\n").encode("ascii")


def run(binary, args, zone):
    return subprocess.run(
        [str(binary), *args],
        env={**os.environ, "TZ": zone, "LC_ALL": "C"},
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=5,
    )


def check(language, result, args, zone, expected):
    actual = (result.returncode, result.stdout, result.stderr)
    if actual == expected:
        return
    label = f"{language}: args={args!r}, TZ={zone}"
    diff = "".join(difflib.unified_diff(
        repr(expected).splitlines(keepends=True),
        repr(actual).splitlines(keepends=True),
        fromfile="expected (status, stdout, stderr)", tofile=label,
    ))
    raise AssertionError(f"{label}\n{diff}")


def cases():
    # A complete Gregorian 400-year cycle covers every leap/weekday combination.
    years = sorted(set(range(2000, 2400)) | {1, 4, 99, 100, 399, 400, 1582, 1900, 9999})
    for year in years:
        yield [str(year)], "UTC", (0, expected_year(year), b"")

    # Individual months exercise exact padding, 4/5/6-week layouts and endpoints.
    for year in (1, 4, 100, 400, 1582, 1900, 2000, 2024, 2026, 2100, 2400, 9999):
        for month in range(1, 13):
            yield [str(month), str(year)], "UTC", (0, expected_month(year, month), b"")

    for args, year, month in (
        (["0001"], 1, None), (["0" * 1000 + "9999"], 9999, None),
        (["0002", "002024"], 2024, 2),
        (["0" * 1000 + "12", "0001"], 1, 12),
    ):
        output = expected_year(year) if month is None else expected_month(year, month)
        yield args, "UTC", (0, output, b"")

    # DST at midnight and the skipped 2011-12-30 in Pacific/Apia must not
    # change an explicitly requested Gregorian month.
    zones = ("UTC", "Asia/Singapore", "America/New_York", "America/Havana",
             "Pacific/Apia", "Pacific/Kiritimati", "Etc/GMT+12")
    for zone in zones:
        for year, month in ((2011, 12), (2015, 11), (2024, 3), (2024, 11)):
            yield [str(month), str(year)], zone, (0, expected_month(year, month), b"")

    invalid_numbers = (
        "", "0", "0000", "-1", "+1", "10000", "2147483647", "2147483648",
        "4294967296", "9223372036854775808", "9" * 1000, "2026x", "2026.0",
        "2e3", "0x7EA", "2_026", " 2026", "2026 ", "\t2026", "2026\n",
        "２０２６", "٢٠٢٦", "--help", "-h", "--", "foo",
    )
    for number in invalid_numbers:
        yield [number], "UTC", (2, b"", USAGE)
        yield ["1", number], "UTC", (2, b"", USAGE)
    for month in ("", "0", "13", "-1", "+1", "1.0", "0x1", " 1", "1 ", "１", "9" * 1000):
        yield [month, "2026"], "UTC", (2, b"", USAGE)
    for args in (["1", "2026", "extra"], ["1", "2", "3", "4"], ["--", "2026"]):
        yield args, "UTC", (2, b"", USAGE)


def main():
    binaries = {language: ROOT / language / "bin" / "cal" for language in LANGUAGES}
    for binary in binaries.values():
        if not binary.is_file():
            raise RuntimeError(f"Missing {binary}; run `make build` first")
    test_cases = list(cases())
    total = 0
    for language, binary in binaries.items():
        for args, zone, expected in test_cases:
            check(language, run(binary, args, zone), args, zone, expected)
            total += 1
        # Read the clock on either side of execution to tolerate a month rollover.
        for zone in ("UTC", "Asia/Singapore", "America/New_York", "Pacific/Kiritimati", "Etc/GMT+12"):
            before = datetime.now(ZoneInfo(zone))
            result = run(binary, [], zone)
            after = datetime.now(ZoneInfo(zone))
            allowed = {expected_month(date.year, date.month) for date in (before, after)}
            if result.returncode != 0 or result.stderr or result.stdout not in allowed:
                check(language, result, [], zone, (0, expected_month(after.year, after.month), b""))
            total += 1
        print(f"PASS {language}: {len(test_cases) + 5} cases", flush=True)
    print(f"PASS: {total} executions across {len(LANGUAGES)} languages", flush=True)


if __name__ == "__main__":
    try:
        main()
    except (AssertionError, RuntimeError, subprocess.TimeoutExpired) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        sys.exit(1)
