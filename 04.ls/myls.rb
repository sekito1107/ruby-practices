#!/usr/bin/env ruby
# frozen_string_literal: true

DISPLAY_COLUMNS_COUNT = 3

def main
  argument_type = argument_parse(ARGV[0]) if ARGV[0]
  directory_files = []

  case argument_type
  when :invalid
    display_error_message
  when :file_path
    display_file_results(ARGV[0])
  when :directory_path
    directory_files = Dir.glob("#{ARGV[0]}/*").map(&File.method(:basename))
  else
    directory_files = Dir.glob('*')
  end

  rows_count = calculate_display_rows(directory_files)
  formatted_deta = create_formatted_deta(rows_count, directory_files)
  display_directory_results(rows_count, formatted_deta)
end

def argument_parse(argument)
  if File.directory?(argument)
    :directory_path
  elsif File.file?(argument)
    :file_path
  else
    :invalid
  end
end

def display_error_message
  puts "'#{ARGV[0]}' にアクセスできません：そのようなファイルやディレクトリはありません"
  exit
end

def display_file_results(file_path)
  specified_path = file_path[0] == '~' ? File.expand_path(file_path) : file_path
  puts specified_path
  exit
end

def calculate_display_rows(directory_files)
  (directory_files.size + DISPLAY_COLUMNS_COUNT - 1) / DISPLAY_COLUMNS_COUNT
end

def create_formatted_deta(rows_count, directory_files)
  directory_files.each_slice(rows_count).to_a
end

def display_directory_results(rows_count, formatted_deta)
  max_string_width = calculate_string_width(formatted_deta)
  rows_count.times do |row|
    DISPLAY_COLUMNS_COUNT.times do |col|
      wide_chars_count = count_characters(formatted_deta[col][row]) || 0
      print formatted_deta[col][row].to_s.ljust(max_string_width + 2 - wide_chars_count)
    end
    puts
  end
end

def calculate_string_width(formatted_data)
  formatted_data.flatten.map do |str|
    str.each_char.map { |c| c.bytesize > 1 ? 2 : 1 }.sum
  end.max
end

def count_characters(file_name)
  file_name.each_char.count { |char| char.bytesize > 1 } if !!(file_name =~ /[^[:ascii:]]/)
end

main
