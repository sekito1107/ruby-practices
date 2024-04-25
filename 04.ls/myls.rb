#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

DISPLAY_COLUMNS_COUNT = 3

PERMISSION_MAP = {
  '0': '---',
  '1': '--x',
  '2': '-w-',
  '3': '-wx',
  '4': 'r--',
  '5': 'r-x',
  '6': 'rw-',
  '7': 'rwx'
}.freeze

FILE_TYPE_MAP = {
  '01': 'p',
  '02': 'c',
  '04': 'd',
  '06': 'b',
  '10': '-',
  '12': 'l',
  '14': 's'
}.freeze

def run
  options = fetch_options!(ARGV)
  selected_files = ARGV.empty? ? ['.'] : ARGV
  sorted_selected_files = sort_selected_files(selected_files, options[:r])

  result_data = create_result_data(sorted_selected_files, options)

  result_display(result_data, selected_files.size >= 2, options[:l])
end

def fetch_options!(command_line_argument)
  options = {
    r: false,
    l: false
  }
  opt = OptionParser.new
  opt.on('-r') { options[:r] = true }
  opt.on('-l') { options[:l] = true }
  opt.parse!(command_line_argument)
  options
end

def sort_selected_files(selected_files, reverse_order)
  reverse_order ? selected_files.sort.reverse : selected_files.sort
end

def create_result_data(selected_files, options)
  result_data = initialize_result_data
  selected_files.each do |filenames|
    data_type = check_file_type(filenames)
    case data_type
    when :directory_path
      result_data[:sorted_directories] << create_sorted_directory(filenames, options[:r], options[:l])
    when :file_path
      result_data[:file_results] << create_detail_dete(filenames, options[:l])
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

def check_file_type(filenames)
  if File.directory?(filenames)
    :directory_path
  elsif File.file?(filenames)
    :file_path
  else
    :invalid
  end
end

def create_sorted_directory(filenames, reverse_order, detail_order)
  directory_files = Dir.glob("#{filenames}/*").map { File.basename(_1) }
  directory_files = directory_files.reverse if reverse_order

  directory_name = filenames

  row_count = calculate_row_count(directory_files) unless detail_order
  formatted_data = []
  directory_kbyte_size = 0
  if detail_order
    directory_files.each do |target_file|
      formatted_data << create_detail_dete(target_file, detail_order, filenames)
      directory_kbyte_size += calc_directory_mbyte_size(target_file, filenames)
    end
  else
    formatted_data = create_formatted_data(directory_files, row_count)
  end
  {
    directory_kbyte_size:,
    directory_name:,
    row_count:,
    formatted_data:
  }
end

def create_detail_dete(file_names, detail_order, base_directory = '')
  return file_names unless detail_order

  target_path = base_directory.empty? ? file_names : "#{base_directory}/#{file_names}"
  stat = File.stat(target_path)
  file_info = {
    permissions: retrieve_permisson(format('%06o', stat.mode)),
    link_count: stat.nlink.to_s,
    user_name: Etc.getpwuid(stat.uid).name,
    group_name: Etc.getgrgid(stat.gid).name,
    file_size: format('%4s', stat.size.to_s),
    time_stamp: stat.mtime.strftime('%-m月 %-d %H:%M').sub(/(\d+)月/, ' \1月').sub(/(?<=月\s)([1-9])(?!\d)/, ' \1'),
    file_name: file_names
  }
  file_info.values.join(' ')
end

def retrieve_permisson(file_deta)
  file_type = FILE_TYPE_MAP[:"#{file_deta[0..1]}"]
  owner_permission = PERMISSION_MAP[:"#{file_deta[3]}"]
  group_permission = PERMISSION_MAP[:"#{file_deta[4]}"]
  other_permission = PERMISSION_MAP[:"#{file_deta[5]}"]
  base_permissions = file_type + owner_permission + group_permission + other_permission

  apply_special_permissions(base_permissions, file_deta[2])
end

def apply_special_permissions(permissions, special_permissions)
  modified_permissions = permissions.dup
  case special_permissions
  when 1
    modified_permissions[8] = modified_permissions[8] == x ? 't' : 'T'
  when 2
    modified_permissions[5] = modified_permissions[5] == x ? 's' : 'S'
  when 3
    modified_permissions[2] = modified_permissions[2] == x ? 's' : 'S'
  end
  modified_permissions
end

def calc_directory_mbyte_size(file_name, base_directory)
  target_path = base_directory.empty? ? filename : "#{base_directory}/#{file_name}"
  File.stat(target_path).size / 1000
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

def result_display(result_data, multiple_files_received, detail_order)
  display_error_messages(result_data[:error_messages]) unless result_data[:error_messages].empty?
  display_file_results(result_data[:file_results], !result_data[:sorted_directories].empty?, detail_order) unless result_data[:file_results].empty?
  directory_results(result_data[:sorted_directories], multiple_files_received, detail_order) unless result_data[:sorted_directories].empty?
end

def display_error_messages(error_messages)
  error_messages.each { puts _1 }
end

def display_file_results(file_results, need_additional_line_break, detail_order)
  if detail_order
    puts file_results
  else
    puts file_results.join(' ')
  end
  puts if need_additional_line_break
end

def directory_results(sorted_directories, multiple_files_received, detail_order)
  sorted_directories.each.with_index do |directory_data, directory_number|
    display_file_name(directory_data[:directory_name], !directory_data[:formatted_data].all?([''])) if multiple_files_received
    if detail_order
      display_detail_directory_results(directory_data[:directory_kbyte_size], directory_data[:formatted_data])
    else
      display_default_directory_results(directory_data[:formatted_data], directory_data[:row_count])
    end
    puts if sorted_directories.size - 1 != directory_number
  end
end

def display_detail_directory_results(directory_size, detail_data)
  puts "合計 #{directory_size}"
  detail_data.each do |data|
    puts data
  end
end

def display_default_directory_results(formatted_data, row_count)
  max_column_widths = calculate_max_column_widths(formatted_data)
  result_data = Array.new(row_count) do |row|
    Array.new(DISPLAY_COLUMNS_COUNT) do |col|
      target_data = formatted_data[col][row]
      wide_chars_count = count_multibyte_characters(target_data) || 0
      target_data.to_s.ljust((max_column_widths[col] || 0) + 2 - wide_chars_count)
    end.join
  end.join("\n")
  puts result_data
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
