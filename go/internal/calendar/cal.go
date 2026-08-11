package calendar

import (
	"fmt"
	"io"
	"strings"
	"time"
)

const monthWidth = 20

// Today returns current year, month (1-12) and day
func Today() (year int, month int, day int) {
	t := time.Now()
	return t.Year(), int(t.Month()), t.Day()
}

func center(s string, width int) string {
	if len(s) >= width {
		return s
	}
	pad := width - len(s)
	left := pad / 2
	return strings.Repeat(" ", left) + s + strings.Repeat(" ", pad-left)
}

func monthLines(year int, month int) []string {
	var lines []string
	t := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC)
	header := fmt.Sprintf("%s %d", t.Month().String(), year)
	lines = append(lines, center(header, monthWidth))
	lines = append(lines, "Su Mo Tu We Th Fr Sa")

	// build weeks
	firstWeekday := int(t.Weekday()) // 0=Sunday
	daysInMonth := daysIn(month, year)

	week := make([]string, 0, 7)
	for i := 0; i < firstWeekday; i++ {
		week = append(week, "  ")
	}
	for d := 1; d <= daysInMonth; d++ {
		week = append(week, fmt.Sprintf("%2d", d))
		if len(week) == 7 {
			lines = append(lines, strings.Join(week, " "))
			week = make([]string, 0, 7)
		}
	}
	if len(week) > 0 {
		for len(week) < 7 {
			week = append(week, "  ")
		}
		lines = append(lines, strings.Join(week, " "))
	}

	// ensure we have header + weekdays + 6 week lines
	for len(lines) < 8 {
		lines = append(lines, strings.Repeat(" ", monthWidth))
	}

	return lines
}

func daysIn(month int, year int) int {
	m := time.Month(month)
	// day 0 of next month is last day of this month
	t := time.Date(year, m+1, 0, 0, 0, 0, 0, time.UTC)
	return t.Day()
}

// PrintMonth prints one month to writer
func PrintMonth(w io.Writer, year int, month int) {
	lines := monthLines(year, month)
	for _, l := range lines {
		fmt.Fprintln(w, l)
	}
}

// PrintYear prints the whole year in 3-column layout
func PrintYear(w io.Writer, year int) {
	// 3 months per row
	for quarter := 1; quarter <= 12; quarter += 3 {
		m1 := monthLines(year, quarter)
		m2 := monthLines(year, quarter+1)
		m3 := monthLines(year, quarter+2)

		// each block has 8 lines
		for i := 0; i < 8; i++ {
			left := padRight(m1[i], monthWidth)
			mid := padRight(m2[i], monthWidth)
			right := padRight(m3[i], monthWidth)
			fmt.Fprintln(w, left+"  "+mid+"  "+right)
		}
		fmt.Fprintln(w)
	}
}

func padRight(s string, width int) string {
	if len(s) >= width {
		return s
	}
	return s + strings.Repeat(" ", width-len(s))
}
