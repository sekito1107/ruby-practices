#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
DISPLAY_COLUMNS_COUNT = 3
DISPLAY_WIDTH = 18

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

  row_size = calculate_row_size(directory_files)
  display_data = create_display_data(row_size, directory_files)
  display_directory_results(row_size, display_data)
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
end

def display_file_results(file_path)
  specified_path = file_path[0] == '~' ? Pathname.new(file_path).expand_path('~') : file_path
  puts specified_path
end

def calculate_row_size(directory_files)
  (directory_files.size + DISPLAY_COLUMNS_COUNT - 1) / DISPLAY_COLUMNS_COUNT - 1
end

def create_display_data(row_size, directory_files)
  directory_files.each_slice(row_size + 1).to_a
end

def display_directory_results(row_size, display_data)
  (row_size + 1).times do |row|
    DISPLAY_COLUMNS_COUNT.times do |col|
      wide_chars_count = count_characters(display_data[col][row]) || 0
      print display_data[col][row].to_s.ljust(DISPLAY_WIDTH - wide_chars_count)
    end
    puts
  end
  puts
end

def count_characters(file_name)
  file_name.each_char.count { |char| char.bytesize > 1 } if !!(file_name =~ /[^[:ascii:]]/)
end

main
