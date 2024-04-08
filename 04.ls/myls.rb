#!/usr/bin/env ruby
# frozen_string_literal: true

DISPLAY_COLUMNS_COUNT = 3

def run
  multiple_arguments_received = false
  sorted_directories = {}
  empty_directories = []
  error_messages = []
  file_results = []

  main(0, file_results, error_messages, empty_directories, sorted_directories) if ARGV.empty?

  ARGV.size.times do |index|
    main(index, file_results, error_messages, empty_directories, sorted_directories)
  end

  multiple_arguments_received = true if ARGV.size >= 2
  result_display(file_results, empty_directories, error_messages, sorted_directories, multiple_arguments_received)
end

def main(index, file_results, error_messages, empty_directories, sorted_directories)
  data_type = :directory_path
  data_type = command_line_argument_type(ARGV[index]) if ARGV[index]
  sorted_directories[:directory_count] ||= 0
  sorted_directories[:directory_name] ||= []
  case data_type
  when :invalid
    error_messages << create_error_messages(index)
  when :file_path
    file_results << create_display_file_results(ARGV[index])
  when :directory_path
    directory_files = create_directory_file(index, sorted_directories, empty_directories)
    sorted_directories[:rows_count] ||= []
    sorted_directories[:rows_count] << calculate_row_count(directory_files)
    sorted_directories[:formatted_datas] ||= []
    sorted_directories[:formatted_datas] << create_formatted_data(directory_files, sorted_directories)
  end
end

def create_directory_file(index, sorted_directories, empty_directories)
  directory_files = if ARGV[index]
                      Dir.glob("#{ARGV[index]}/*").map { File.basename(_1) }
                    else
                      Dir.glob('*')
                    end
  if directory_files.empty?
    empty_directories << ARGV[index].to_s
  else
    sorted_directories[:directory_count] += 1
    sorted_directories[:directory_name] << ARGV[index]
  end
  directory_files
end

def command_line_argument_type(command_line_argument_data)
  if File.directory?(command_line_argument_data)
    :directory_path
  elsif File.file?(command_line_argument_data)
    :file_path
  else
    :invalid
  end
end

def create_error_messages(index)
  "ls: '#{ARGV[index]}' にアクセスできません：そのようなファイルやディレクトリはありません"
end

def create_display_file_results(file_path)
  file_path == '~' ? File.expand_path(file_path) : file_path
end

def calculate_row_count(directory_files)
  rows_count = (directory_files.size + DISPLAY_COLUMNS_COUNT - 1) / DISPLAY_COLUMNS_COUNT
  rows_count.zero? ? 1 : rows_count
end

def create_formatted_data(directory_files, sorted_directories)
  row_count = sorted_directories[:rows_count][sorted_directories[:directory_count] - 1]
  formatted_data = directory_files.each_slice(row_count).to_a
  formatted_data << [''] while formatted_data.size < DISPLAY_COLUMNS_COUNT
  formatted_data
end

def result_display(file_results, empty_directories, error_messages, sorted_directories, multiple_arguments_received)
  display_error_messages(error_messages) unless error_messages.empty?
  display_file_results(file_results, empty_directories, sorted_directories) unless file_results.empty?
  display_empty_message(empty_directories, sorted_directories, multiple_arguments_received) unless empty_directories.empty?
  display_directory_results(sorted_directories, multiple_arguments_received) unless sorted_directories.empty?
end

def display_error_messages(error_messages)
  error_messages.each { puts _1 }
end

def display_file_results(file_results, empty_directories, sorted_directories)
  file_results.sort.each { print "#{_1}  " }
  puts
  puts if !sorted_directories.empty? || !empty_directories.empty?
end

def display_empty_message(empty_directories, sorted_directories, multiple_arguments_received)
  unless multiple_arguments_received
    print ''
    exit
  end
  empty_directories.each.with_index do |directory_name, empty_index|
    puts "#{directory_name}:"
    puts unless empty_directories.size - 1 == empty_index || sorted_directories.empty?
  end
end

def display_directory_results(sorted_directories, multiple_arguments_received)
  sorted_directories[:directory_count].times do |directory_number|
    puts if directory_number.positive? && multiple_arguments_received
    puts "#{sorted_directories[:directory_name][directory_number]}:" if multiple_arguments_received
    max_column_widths = calculate_max_column_widths(sorted_directories[:formatted_datas][directory_number])
    sorted_directories[:rows_count][directory_number].times do |row|
      DISPLAY_COLUMNS_COUNT.times do |col|
        wide_chars_count = count_multibyte_characters(sorted_directories[:formatted_datas][directory_number][col][row]) || 0
        print sorted_directories[:formatted_datas][directory_number][col][row].to_s.ljust((max_column_widths[col] || 0) + 2 - wide_chars_count)
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
