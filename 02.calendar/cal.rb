#!/usr/bin/env ruby
require 'date'
require 'optparse'

#オプションの取得
options = ARGV.getopts('m:', 'y:').transform_values! {|value| value.to_i unless value == nil}
options["m"] ||= Date.today.month
options["y"] ||= Date.today.year

#月初め、月末のデータを取得
month_firstday = Date.new(options["y"], options["m"], 1)
month_lastday = Date.new(options["y"], options["m"], -1)
firstday_wday = month_firstday.wday

#カレンダーのフォーマットを作成
puts "      " + "#{month_firstday.month}月 #{month_firstday.year}"
puts "日 月 火 水 木 金 土"
print "   " * (firstday_wday)

#日付を表示
(month_firstday..month_lastday).each do |date|
  firstday_wday += 1
  if date == Date.today
    print "\e[7m#{date.strftime("%e")}\e[0m"
  else
  print date.strftime("%e")
  end
  date.saturday? ? (puts "") : (print " ")
end
puts ""
