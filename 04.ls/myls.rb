#!/usr/bin/env ruby
# frozen_string_literal: true

DISPLAY_COLUMNS_COUNT = 3

def run
  command_line_argument = ARGV
  multiple_arguments_received = false

  result_datas = {
    directory_count: 0,
    sorted_directories: [],
    empty_directories: [],
    error_messages: [],
    file_results: []
  }

  result_datas = create_result_datas(command_line_argument, result_datas)

  multiple_arguments_received = true if command_line_argument.size >= 2
  result_display(result_datas, multiple_arguments_received)
end

def create_result_datas(command_line_argument, result_datas)
  if command_line_argument.empty?
    result_datas[:directory_count] += 1
    result_datas[:sorted_directories] << create_sorted_directory(0, nil)
  else
    command_line_argument.size.times do |index|
      data_type = command_line_argument_type(command_line_argument[index])
      case data_type
      when :directory_path
        result_datas[:directory_count] += 1
        result_datas[:sorted_directories] << create_sorted_directory(index, command_line_argument)
      when :file_path
        result_datas[:file_results] << command_line_argument[index]
      when :empty_directory
        result_datas[:empty_directories] << command_line_argument[index]
      when :invalid
        result_datas[:error_messages] << create_error_message(index, command_line_argument)
      end
    end
  end
  result_datas
end

def command_line_argument_type(command_line_argument_data)
  if File.directory?(command_line_argument_data)
    return :empty_directory if Dir.glob("#{command_line_argument_data}/*").empty?

    :directory_path
  elsif File.file?(command_line_argument_data)
    :file_path
  else
    :invalid
  end
end

def create_sorted_directory(index, command_line_argument)
  if command_line_argument
    directory_files = Dir.glob("#{command_line_argument[index]}/*").map { File.basename(_1) }
    directory_name = command_line_argument[index]
  else
    directory_files = Dir.glob('*')
  end
  row_count = calculate_row_count(directory_files)
  formatted_datas = create_formatted_data(directory_files, row_count)

  {
    directory_name:,
    row_count:,
    formatted_datas:
  }
end

def create_error_message(index, command_line_argument)
  "ls: '#{command_line_argument[index]}' にアクセスできません：そのようなファイルやディレクトリはありません"
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

def result_display(result_datas, multiple_arguments_received)
  display_error_messages(result_datas) unless result_datas[:error_messages].empty?
  display_file_results(result_datas) unless result_datas[:file_results].empty?
  display_empty_message(result_datas, multiple_arguments_received) unless result_datas[:empty_directories].empty?
  display_directory_results(result_datas, multiple_arguments_received) unless result_datas[:sorted_directories].empty?
end

def display_error_messages(result_datas)
  result_datas[:error_messages].each { puts _1 }
end

def display_file_results(result_datas)
  result_datas[:file_results].sort.each { print "#{_1}  " }
  puts
  puts if !result_datas[:sorted_directories].empty? || !result_datas[:empty_directories].empty?
end

def display_empty_message(result_datas, multiple_arguments_received)
  unless multiple_arguments_received
    print ''
    exit
  end
  result_datas[:empty_directories].each.with_index do |directory_name, empty_index|
    puts "#{directory_name}:"
    puts if result_datas[:empty_directories].size - 1 != empty_index || !result_datas[:sorted_directories].empty?
  end
end

def display_directory_results(result_datas, multiple_arguments_received)
  result_datas[:directory_count].times do |directory_number|
    target_directory_data = result_datas[:sorted_directories][directory_number]
    puts if directory_number.positive? && multiple_arguments_received
    puts "#{target_directory_data[:directory_name]}:" if multiple_arguments_received
    max_column_widths = calculate_max_column_widths(target_directory_data[:formatted_datas])
    target_directory_data[:row_count].times do |row|
      DISPLAY_COLUMNS_COUNT.times do |col|
        wide_chars_count = count_multibyte_characters(target_directory_data[:formatted_datas][col][row]) || 0
        print target_directory_data[:formatted_datas][col][row].to_s.ljust((max_column_widths[col] || 0) + 2 - wide_chars_count)
      end
      puts
    end
  end
end

def calculate_max_column_widths(formatted_data)
  formatted_data.map do |col_data|
    col_data.map do |str|
      str.each_char.map { |c| c.bytesize > 1 ? 2 : 1 }.sum
    end.max
  end
end

def count_multibyte_characters(file_name)
  file_name ||= ''
  file_name.each_char.count { |char| char.bytesize > 1 }
end

run
