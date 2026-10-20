package main

import (
	"fmt"
	"os"

	"cal/internal/calendar"
)

func usage() {
	fmt.Fprintln(os.Stderr, "Usage: cal [month] year  OR  cal year  OR  cal")
	os.Exit(2)
}

// Parse only ASCII decimal digits, checking the bound before any overflow.
func parseNumber(text string, maximum int) int {
	if text == "" {
		usage()
	}
	value := 0
	for _, digit := range text {
		if digit < '0' || digit > '9' {
			usage()
		}
		value = value*10 + int(digit-'0')
		if value > maximum {
			usage()
		}
	}
	if value < 1 {
		usage()
	}
	return value
}

func main() {
	args := os.Args[1:]

	switch len(args) {
	case 0:
		// current month
		y, m, _ := calendar.Today()
		calendar.PrintMonth(os.Stdout, y, m)
	case 1:
		// treat as year
		year := parseNumber(args[0], 9999)
		calendar.PrintYear(os.Stdout, year)
	case 2:
		// month year
		month := parseNumber(args[0], 12)
		year := parseNumber(args[1], 9999)
		calendar.PrintMonth(os.Stdout, year, month)
	default:
		usage()
	}
}
