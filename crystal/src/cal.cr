MONTH_WIDTH = 20
WEEK_HEADER = "Su Mo Tu We Th Fr Sa"
MONTH_NAMES = [
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
]

def usage : NoReturn
  STDERR.puts "Usage: cal [month] year  OR  cal year  OR  cal"
  exit 2
end

def center(text : String, width : Int32) : String
  return text if text.bytesize >= width

  padding = width - text.bytesize
  left = padding // 2
  " " * left + text + " " * (padding - left)
end

def pad_right(text : String, width : Int32) : String
  return text if text.bytesize >= width

  text + " " * (width - text.bytesize)
end

def leap_year?(year : Int32) : Bool
  (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
end

def days_in_month(year : Int32, month : Int32) : Int32
  case month
  when 1, 3, 5, 7, 8, 10, 12 then 31
  when 4, 6, 9, 11           then 30
  when 2                     then leap_year?(year) ? 29 : 28
  else
    raise "invalid month"
  end
end

# Zeller's congruence, converted to 0 = Sunday through 6 = Saturday.
def first_weekday(year : Int32, month : Int32) : Int32
  adjusted_year = year
  adjusted_month = month
  if adjusted_month <= 2
    adjusted_year -= 1
    adjusted_month += 12
  end

  century = adjusted_year // 100
  year_of_century = adjusted_year % 100
  zeller = (1 + (13 * (adjusted_month + 1)) // 5 + year_of_century +
            year_of_century // 4 + century // 4 + 5 * century) % 7
  (zeller + 6) % 7
end

def month_lines(year : Int32, month : Int32) : Array(String)
  lines = [] of String
  lines << center("#{MONTH_NAMES[month - 1]} #{year}", MONTH_WIDTH)
  lines << WEEK_HEADER

  weekday = first_weekday(year, month)
  total_days = days_in_month(year, month)
  week = Array(String).new(7, "  ")
  day = 1

  while day <= total_days
    week[weekday] = day.to_s.rjust(2)
    day += 1
    weekday += 1
    next unless weekday == 7

    lines << week.join(" ")
    week = Array(String).new(7, "  ")
    weekday = 0
  end

  lines << week.join(" ") unless weekday == 0
  while lines.size < 8
    lines << " " * MONTH_WIDTH
  end
  lines
end

def print_month(year : Int32, month : Int32)
  month_lines(year, month).each { |line| puts line }
end

def print_year(year : Int32)
  [1, 4, 7, 10].each do |first_month|
    left = month_lines(year, first_month)
    middle = month_lines(year, first_month + 1)
    right = month_lines(year, first_month + 2)

    8.times do |index|
      puts "#{pad_right(left[index], MONTH_WIDTH)}  #{pad_right(middle[index], MONTH_WIDTH)}  #{pad_right(right[index], MONTH_WIDTH)}"
    end
    puts
  end
end

def parse_int(value : String) : Int32
  value.to_i?(whitespace: false) || usage
end

def parse_month(value : String) : Int32
  month = parse_int(value)
  usage unless (1..12).includes?(month)
  month
end

case ARGV.size
when 0
  now = Time.local
  print_month(now.year, now.month)
when 1
  print_year(parse_int(ARGV[0]))
when 2
  print_month(parse_int(ARGV[1]), parse_month(ARGV[0]))
else
  usage
end
