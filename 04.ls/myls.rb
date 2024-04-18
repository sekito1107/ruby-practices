#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

DISPLAY_COLUMNS_COUNT = 3

def run
  options = option_initialize

  selected_files = ARGV.empty? ? ['.'] : ARGV

  result_data = create_result_data(selected_files, options)

  result_display(result_data, selected_files.size >= 2)
end

def initialize_option
  options = {
    opt_a: false
  }
  opt = OptionParser.new
  opt.on('-a') { options[:opt_a] = true }
  opt.parse!(ARGV)
  options
end

def create_result_data(selected_files, options)
  result_data = initialize_result_data
  selected_files.sort.each do |filenames|
    data_type = file_type(filenames)
    case data_type
    when :directory_path
      result_data[:sorted_directories] << create_sorted_directory(filenames, options[:opt_a])
    when :file_path
      result_data[:file_results] << filenames
    when :invalid
      result_data[:error_messages] << create_error_message(filenames)
    end
  end
  result_data
end

def initialize_result_data
  {
    sorted_directories: [],
    empty_directories: [],
    error_messages: [],
    file_results: []
  }
end

def file_type(filenames)
  if File.directory?(filenames)
    :directory_path
  elsif File.file?(filenames)
    :file_path
  else
    :invalid
  end
end

def create_sorted_directory(filenames, opt_a)
  directory_files = if opt_a
                      Dir.glob("#{filenames}/*", File::FNM_DOTMATCH).map { File.basename(_1) }
                    else
                      Dir.glob("#{filenames}/*").map { File.basename(_1) }
                    end
  directory_name = filenames

  row_count = calculate_row_count(directory_files)
  formatted_data = create_formatted_data(directory_files, row_count)

  {
    directory_name:,
    row_count:,
    formatted_data:
  }
end

def create_error_message(filenames)
  "ls: '#{filenames}' にアクセスできません：そのようなファイルやディレクトリはありません"
end

def calculate_row_count(directory_files)
  row_count = (directory_files.size + DISPLAY_COLUMNS_COUNT - 1) / DISPLAY_COLUMNS_COUNT
  row_count.zero? ? 1 : row_count
end

def create_formatted_data(directory_files, row_count)
  formatted_data = directory_files.each_slice(row_count).to_a
  formatted_data << [''] while formatted_data.size < DISPLAY_COLUMNS_COUNT
  formatted_data
end

def result_display(result_data, multiple_files_received)
  display_error_messages(result_data[:error_messages]) unless result_data[:error_messages].empty?
  display_file_results(result_data[:file_results], !result_data[:sorted_directories].empty?) unless result_data[:file_results].empty?
  display_directory_results(result_data[:sorted_directories], multiple_files_received) unless result_data[:sorted_directories].empty?
end

def display_error_messages(error_messages)
  error_messages.each { puts _1 }
end

def display_file_results(file_results, need_additional_line_break)
  puts file_results.sort.join('  ')
  puts if need_additional_line_break
end

def display_directory_results(sorted_directories, multiple_files_received)
  sorted_directories.each.with_index do |directory_data, directory_number|
    display_file_name(directory_data[:directory_name], !directory_data[:formatted_data].all?([''])) if multiple_files_received
    max_column_widths = calculate_max_column_widths(directory_data[:formatted_data])
    result_data = Array.new(directory_data[:row_count]) do |row|
      Array.new(DISPLAY_COLUMNS_COUNT) do |col|
        target_data = directory_data[:formatted_data][col][row]
        wide_chars_count = count_multibyte_characters(target_data) || 0
        target_data.to_s.ljust((max_column_widths[col] || 0) + 2 - wide_chars_count)
      end.join
    end.join("\n")
    puts result_data
    puts if sorted_directories.size - 1 != directory_number
  end
end

def display_file_name(directory_name, need_new_line)
  print "#{directory_name}:"
  puts if need_new_line
end

def calculate_max_column_widths(formatted_data)
  formatted_data.map do |col_data|
    col_data.map do |str|
      str.each_char.map { |c| c.bytesize > 1 ? 2 : 1 }.sum
    end.max
  end
end

def count_multibyte_characters(filename)
  (filename || '').each_char.count { |char| char.bytesize > 1 }
end

run
