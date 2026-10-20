const std = @import("std");
extern "c" fn cal_write(data: [*]const u8, length: usize) void;
extern "c" fn cal_usage() noreturn;
extern "c" fn cal_local_date() i32;

const month_width: usize = 20;
const week_header = "Su Mo Tu We Th Fr Sa";
const month_names = [_][]const u8{
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
};

fn usage() noreturn {
    cal_usage();
}

const MonthBlock = [8][month_width]u8;

fn isLeapYear(year: i32) bool {
    return (@mod(year, 4) == 0 and @mod(year, 100) != 0) or (@mod(year, 400) == 0);
}

fn daysInMonth(year: i32, month: u32) u32 {
    return switch (month) {
        1, 3, 5, 7, 8, 10, 12 => 31,
        4, 6, 9, 11 => 30,
        2 => if (isLeapYear(year)) 29 else 28,
        else => unreachable,
    };
}

fn weekdayOfFirst(year: i32, month: u32) u32 {
    var y = year;
    var m = @as(i32, @intCast(month));
    if (m <= 2) {
        y -= 1;
        m += 12;
    }

    const q: i32 = 1;
    const k = @mod(y, 100);
    const j = @divTrunc(y, 100);
    const h = @mod(q + @divTrunc(13 * (m + 1), 5) + k + @divTrunc(k, 4) + @divTrunc(j, 4) + 5 * j, 7);
    return switch (h) {
        0 => 6,
        1 => 0,
        2 => 1,
        3 => 2,
        4 => 3,
        5 => 4,
        6 => 5,
        else => unreachable,
    };
}

fn fillSpaces(line: *[month_width]u8) void {
    @memset(line, ' ');
}

fn writeCentered(line: *[month_width]u8, text: []const u8) void {
    fillSpaces(line);
    // Valid years are 1..9999, so every English month title fits.
    std.debug.assert(text.len <= month_width);
    const left = (month_width - text.len) / 2;
    @memcpy(line[left .. left + text.len], text);
}

fn writeWeekRow(line: *[month_width]u8, first_weekday: u32, total_days: u32, day_ptr: *u32, week_index: usize) void {
    fillSpaces(line);

    var weekday: u32 = 0;
    while (weekday < 7) : (weekday += 1) {
        const offset = @as(usize, @intCast(weekday * 3));
        const is_blank = (week_index == 0 and weekday < first_weekday) or day_ptr.* > total_days;
        if (!is_blank) {
            const day = day_ptr.*;
            line[offset] = if (day >= 10) @as(u8, '0') + @as(u8, @intCast(day / 10)) else ' ';
            line[offset + 1] = @as(u8, '0') + @as(u8, @intCast(day % 10));
            day_ptr.* += 1;
        }
    }
}

fn buildMonthBlock(year: i32, month: u32) MonthBlock {
    var lines: MonthBlock = undefined;
    var header_buf: [32]u8 = undefined;
    const header = std.fmt.bufPrint(&header_buf, "{s} {}", .{ month_names[month - 1], year }) catch unreachable;
    writeCentered(&lines[0], header);
    @memcpy(lines[1][0..month_width], week_header);

    const first_weekday = weekdayOfFirst(year, month);
    const total_days = daysInMonth(year, month);
    var day: u32 = 1;

    for (0..6) |week_index| {
        writeWeekRow(&lines[week_index + 2], first_weekday, total_days, &day, week_index);
    }

    return lines;
}

fn writeLine(line: []const u8) void {
    cal_write(line.ptr, line.len);
    cal_write("\n", 1);
}

fn printMonth(year: i32, month: u32) void {
    const lines = buildMonthBlock(year, month);
    for (lines) |line| {
        writeLine(&line);
    }
}

fn printYear(year: i32) void {
    var quarter: u32 = 1;
    while (quarter <= 12) : (quarter += 3) {
        const left = buildMonthBlock(year, quarter);
        const middle = buildMonthBlock(year, quarter + 1);
        const right = buildMonthBlock(year, quarter + 2);

        for (0..8) |idx| {
            cal_write(&left[idx], month_width);
            cal_write("  ", 2);
            cal_write(&middle[idx], month_width);
            cal_write("  ", 2);
            cal_write(&right[idx], month_width);
            cal_write("\n", 1);
        }
        cal_write("\n", 1);
    }
}

fn parseNumber(text: []const u8, maximum: i32) i32 {
    if (text.len == 0) usage();
    var value: i32 = 0;
    for (text) |digit| {
        if (digit < '0' or digit > '9') usage();
        value = value * 10 + @as(i32, digit - '0');
        if (value > maximum) usage();
    }
    if (value < 1) usage();
    return value;
}

fn currentYearMonth() struct { year: i32, month: u32 } {
    const date = cal_local_date();
    return .{
        .year = @divTrunc(date, 10000),
        .month = @intCast(@mod(@divTrunc(date, 100), 100)),
    };
}

pub fn main(init: std.process.Init.Minimal) !void {
    var args = std.process.Args.Iterator.init(init.args);
    _ = args.skip();
    const arg1 = args.next();
    const arg2 = args.next();

    if (args.next() != null) usage();

    if (arg1 == null) {
        const today = currentYearMonth();
        printMonth(today.year, today.month);
    } else if (arg2 == null) {
        const year = parseNumber(arg1.?, 9999);
        printYear(year);
    } else {
        const month: u32 = @intCast(parseNumber(arg1.?, 12));
        const year = parseNumber(arg2.?, 9999);
        printMonth(year, month);
    }
}
