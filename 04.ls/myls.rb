#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
DISPLAY_COLUMNS_COUNT = 3
DISPLAY_WIDTH = 18

def sorting_work
  if ARGV[0]
    pathname = Pathname.new(ARGV[0])
    if pathname.directory?
      calculate_array_size(Dir.glob("#{pathname}/*").map(&File.method(:basename)))
    elsif pathname.file?
      if pathname.to_s[0] == '~'
        display_file_results(File.expand_path(pathname))
      else
        display_file_results(pathname)
      end
    else
      error_message = "'#{pathname}' にアクセスできません：そのようなファイルやディレクトリはありません"
      display_error_message(error_message)
    end
    return
  end
  calculate_array_size(Dir.glob('*'))
end

def calculate_array_size(current_directory_files)
  directory_size = current_directory_files.size
  array_size = if (directory_size % DISPLAY_COLUMNS_COUNT).zero?
                 directory_size / DISPLAY_COLUMNS_COUNT - 1
               else
                 directory_size / DISPLAY_COLUMNS_COUNT
               end
  create_display_data(array_size, current_directory_files)
end

def create_display_data(array_size, current_directory_files)
  display_data = []
  current_directory_files.each_slice(array_size + 1) do |slice_data|
    display_data << slice_data
  end
  display_directory_results(array_size, display_data)
end

def display_directory_results(array_size, display_data)
  (array_size + 1).times do |row|
    DISPLAY_COLUMNS_COUNT.times do |col|
      wide_chars_count = count_characters(display_data[col][row]) || 0
      print display_data[col][row].to_s.ljust(DISPLAY_WIDTH - wide_chars_count)
    end
    puts
  end
  puts
end

def count_characters(file_name)
  file_name.each_char.count { |char| char.bytesize > 1 } if contains_wide_chars?(file_name)
end

def contains_wide_chars?(file_name)
  !!(file_name =~ /[^[:ascii:]]/)
end

def display_file_results(file_path)
  puts file_path
end

def display_error_message(error_message)
  puts error_message
end

sorting_work
