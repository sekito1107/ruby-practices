#!/usr/bin/env ruby
# frozen_string_literal: true

DISPLAY_COLUMNS_COUNT = 3

def run
  selected_files = ARGV
  multiple_arguments_received = false

  result_data = create_result_data(selected_files)

  multiple_arguments_received = true if selected_files.size >= 2
  result_display(result_data, multiple_arguments_received)
end

def create_result_data(selected_files)
  result_data = {
    sorted_directories: [],
    empty_directories: [],
    error_messages: [],
    file_results: []
  }

  if selected_files.empty?
    result_data[:sorted_directories] << create_sorted_directory
  else
    selected_files.sort.each do |filenames|
      data_type = file_type(filenames)
      case data_type
      when :directory_path
        result_data[:sorted_directories] << create_sorted_directory(filenames)
      when :file_path
        result_data[:file_results] << filenames
      when :invalid
        result_data[:error_messages] << create_error_message(filenames)
      end
    end
  end
  result_data
end

def file_type(filenames = nil)
  if File.directory?(filenames)
    :directory_path
  elsif File.file?(filenames)
    :file_path
  else
    :invalid
  end
end

def create_sorted_directory(filenames)
  if filenames
    directory_files = Dir.glob("#{filenames}/*").map { File.basename(_1) }
    directory_name = filenames
  else
    directory_files = Dir.glob('*')
  end
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

def result_display(result_data, multiple_arguments_received)
  display_error_messages(result_data) unless result_data[:error_messages].empty?
  display_file_results(result_data) unless result_data[:file_results].empty?
  display_directory_results(result_data, multiple_arguments_received) unless result_data[:sorted_directories].empty?
end

def display_error_messages(result_data)
  result_data[:error_messages].each { puts _1 }
end

def display_file_results(result_data)
  result_data[:file_results].sort.each { print "#{_1}  " }
  puts
  puts unless result_data[:sorted_directories].empty?
end

def display_directory_results(result_data, multiple_arguments_received)
  result_data[:sorted_directories].each.with_index do |directory_data, directory_number|
    puts if directory_number.positive? && multiple_arguments_received
    display_file_name(directory_data) if multiple_arguments_received
    max_column_widths = calculate_max_column_widths(directory_data[:formatted_data])
    directory_data[:row_count].times do |row|
      DISPLAY_COLUMNS_COUNT.times do |col|
        wide_chars_count = count_multibyte_characters(directory_data[:formatted_data][col][row]) || 0
        print directory_data[:formatted_data][col][row].to_s.ljust((max_column_widths[col] || 0) + 2 - wide_chars_count)
      end
      puts
    end
  end
end

def display_file_name(directory_data)
  if directory_data[:formatted_data] == [[''], [''], ['']]
    print "#{directory_data[:directory_name]}:"
  else
    puts "#{directory_data[:directory_name]}:"
  end
end

def calculate_max_column_widths(formatted_data)
  formatted_data.map do |col_data|
    col_data.map do |str|
      str.each_char.map { |c| c.bytesize > 1 ? 2 : 1 }.sum
    end.max
  end
end

def count_multibyte_characters(filenames)
  filenames ||= ''
  filenames.each_char.count { |char| char.bytesize > 1 }
end

run
