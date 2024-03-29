#!/usr/bin/env ruby
require 'date'
require 'optparse'

options = ARGV.getopts('m:', 'y:').transform_values! {|value| value&.to_i }
options["m"] ||= Date.today.month
options["y"] ||= Date.today.year

month_firstday = Date.new(options["y"], options["m"], 1)
month_lastday = Date.new(options["y"], options["m"], -1)
firstday_wday = month_firstday.wday

puts "      " + "#{month_firstday.month}月 #{month_firstday.year}"
puts "日 月 火 水 木 金 土"
print "   " * (firstday_wday)

(month_firstday..month_lastday).each do |date|
  if date == Date.today
    print "\e[7m#{date.strftime("%e")}\e[0m"
  else
    print date.strftime("%e")
  end
  if date.saturday?
    puts
  else
    print(" ")
  end
end
puts
