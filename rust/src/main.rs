use chrono::{Datelike, Local, NaiveDate};
use std::env;
use std::process;

const MONTH_WIDTH: usize = 20;
const WEEK_HEADER: &str = "Su Mo Tu We Th Fr Sa";

fn usage() -> ! {
    eprintln!("Usage: cal [month] year  OR  cal year  OR  cal");
    process::exit(2);
}

fn center(text: &str, width: usize) -> String {
    if text.len() >= width {
        return text.to_string();
    }

    let pad = width - text.len();
    let left = pad / 2;
    format!("{}{}{}", " ".repeat(left), text, " ".repeat(pad - left))
}

fn pad_right(text: &str, width: usize) -> String {
    if text.len() >= width {
        return text.to_string();
    }

    format!("{}{}", text, " ".repeat(width - text.len()))
}

fn days_in_month(year: i32, month: u32) -> u32 {
    let (next_year, next_month) = if month == 12 {
        (year + 1, 1)
    } else {
        (year, month + 1)
    };
    let first_day_next_month =
        NaiveDate::from_ymd_opt(next_year, next_month, 1).expect("valid next month");
    first_day_next_month
        .pred_opt()
        .expect("previous day exists")
        .day()
}

fn month_lines(year: i32, month: u32) -> Vec<String> {
    let first_day = NaiveDate::from_ymd_opt(year, month, 1).expect("valid year/month");
    let mut lines = Vec::with_capacity(8);
    let header = format!("{} {}", first_day.format("%B"), year);
    lines.push(center(&header, MONTH_WIDTH));
    lines.push(WEEK_HEADER.to_string());

    let first_weekday = first_day.weekday().num_days_from_sunday() as usize;
    let total_days = days_in_month(year, month);

    let mut week: Vec<String> = Vec::with_capacity(7);
    for _ in 0..first_weekday {
        week.push("  ".to_string());
    }

    for day in 1..=total_days {
        week.push(format!("{day:>2}"));
        if week.len() == 7 {
            lines.push(week.join(" "));
            week.clear();
        }
    }

    if !week.is_empty() {
        while week.len() < 7 {
            week.push("  ".to_string());
        }
        lines.push(week.join(" "));
    }

    while lines.len() < 8 {
        lines.push(" ".repeat(MONTH_WIDTH));
    }

    lines
}

fn print_month(year: i32, month: u32) {
    for line in month_lines(year, month) {
        println!("{line}");
    }
}

fn print_year(year: i32) {
    for quarter in [1_u32, 4, 7, 10] {
        let left = month_lines(year, quarter);
        let middle = month_lines(year, quarter + 1);
        let right = month_lines(year, quarter + 2);

        for idx in 0..8 {
            println!(
                "{}  {}  {}",
                pad_right(&left[idx], MONTH_WIDTH),
                pad_right(&middle[idx], MONTH_WIDTH),
                pad_right(&right[idx], MONTH_WIDTH)
            );
        }
        println!();
    }
}

fn parse_number(text: &str, maximum: i32) -> i32 {
    if text.is_empty() {
        usage();
    }
    let mut value = 0;
    for digit in text.bytes() {
        if !digit.is_ascii_digit() {
            usage();
        }
        value = value * 10 + i32::from(digit - b'0');
        if value > maximum {
            usage();
        }
    }
    if value < 1 {
        usage();
    }
    value
}

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();

    match args.len() {
        0 => {
            let today = Local::now().date_naive();
            print_month(today.year(), today.month());
        }
        1 => {
            let year = parse_number(&args[0], 9999);
            print_year(year);
        }
        2 => {
            let month = parse_number(&args[0], 12) as u32;
            let year = parse_number(&args[1], 9999);
            print_month(year, month);
        }
        _ => usage(),
    }
}
