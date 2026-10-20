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

def days_in_month(year : Int32, month : Int32) : Int32
  Time.days_in_month(year, month)
end

# Crystal's weekday values are 1 = Monday through 7 = Sunday.
def first_weekday(year : Int32, month : Int32) : Int32
  Time.utc(year, month, 1).day_of_week.to_i % 7
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

def parse_number(text : String, maximum : Int32) : Int32
  usage if text.empty?
  value = 0
  text.each_byte do |digit|
    usage unless digit >= 48 && digit <= 57
    value = value * 10 + digit.to_i - 48
    usage if value > maximum
  end
  usage if value < 1
  value
end

case ARGV.size
when 0
  now = Time.local
  print_month(now.year, now.month)
when 1
  print_year(parse_number(ARGV[0], 9999))
when 2
  print_month(parse_number(ARGV[1], 9999), parse_number(ARGV[0], 12))
else
  usage
end
