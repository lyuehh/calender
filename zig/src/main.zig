const std = @import("std");
const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("time.h");
});

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
    _ = c.fprintf(c.stderr(), "Usage: cal [month] year  OR  cal year  OR  cal\n");
    std.process.exit(2);
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
    const actual = @min(text.len, month_width);
    const left = (month_width - actual) / 2;
    @memcpy(line[left .. left + actual], text[0..actual]);
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
    _ = c.fwrite(line.ptr, 1, line.len, c.stdout());
    _ = c.fputc('\n', c.stdout());
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
            _ = c.fwrite(&left[idx], 1, month_width, c.stdout());
            _ = c.fwrite("  ", 1, 2, c.stdout());
            _ = c.fwrite(&middle[idx], 1, month_width, c.stdout());
            _ = c.fwrite("  ", 1, 2, c.stdout());
            _ = c.fwrite(&right[idx], 1, month_width, c.stdout());
            _ = c.fputc('\n', c.stdout());
        }
        _ = c.fputc('\n', c.stdout());
    }
}

fn parseI32(value: []const u8) i32 {
    return std.fmt.parseInt(i32, value, 10) catch usage();
}

fn parseMonth(value: []const u8) u32 {
    const month = std.fmt.parseInt(u32, value, 10) catch usage();
    if (month < 1 or month > 12) usage();
    return month;
}

fn currentYearMonth() struct { year: i32, month: u32 } {
    var now = c.time(null);
    var local_tm: c.struct_tm = undefined;
    _ = c.localtime_r(&now, &local_tm);
    return .{
        .year = local_tm.tm_year + 1900,
        .month = @as(u32, @intCast(local_tm.tm_mon + 1)),
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
        const year = parseI32(arg1.?);
        printYear(year);
    } else {
        const month = parseMonth(arg1.?);
        const year = parseI32(arg2.?);
        printMonth(year, month);
    }
}
