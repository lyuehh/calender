package main

import (
    "flag"
    "fmt"
    "os"
    "strconv"

    "cal/internal/calendar"
)

func usage() {
    fmt.Fprintln(os.Stderr, "Usage: cal [month] year  OR  cal year  OR  cal")
    os.Exit(2)
}

func main() {
    flag.Parse()
    args := flag.Args()

    switch len(args) {
    case 0:
        // current month
        y, m, _ := calendar.Today()
        calendar.PrintMonth(os.Stdout, y, m)
    case 1:
        // treat as year
        year, err := strconv.Atoi(args[0])
        if err != nil {
            usage()
        }
        calendar.PrintYear(os.Stdout, year)
    case 2:
        // month year
        month, err1 := strconv.Atoi(args[0])
        year, err2 := strconv.Atoi(args[1])
        if err1 != nil || err2 != nil || month < 1 || month > 12 {
            usage()
        }
        calendar.PrintMonth(os.Stdout, year, month)
    default:
        usage()
    }
}
