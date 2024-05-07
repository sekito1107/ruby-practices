#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  options, file_paths = fetch_options!(ARGV)
  count_data = file_paths.empty? ? count_stdin($stdin) : count_files(file_paths, file_paths.size > 1)
  return if count_data.empty?

  length = calculate_length(file_paths, count_data[-1]) if count_data
  puts(count_data.map { |data| format_count_data(length, data, options) })
end

def fetch_options!(command_line_argument)
  options = {
    line: false,
    word: false,
    char: false
  }
  opt = OptionParser.new
  opt.on('-l') { options[:line] = true }
  opt.on('-w') { options[:word] = true }
  opt.on('-c') { options[:char] = true }
  file_paths = opt.parse!(command_line_argument)

  if !options[:line] && !options[:word] && !options[:char]
    options[:line] = true
    options[:word] = true
    options[:char] = true
  end

  [options, file_paths]
end

def count_stdin(content)
  [create_count_data(content.read, nil)]
end

def count_files(file_paths, multiple_files)
  count_data = file_paths.map do |file_path|
    if File.file?(file_path)
      create_count_data(File.read(file_path), file_path)
    elsif File.directory?(file_path)
      directory_data(file_path)
    else
      create_error_messages(file_path)
    end
  end
  count_data << create_sum_data(count_data.compact) if multiple_files
  count_data.compact
end

def create_count_data(content, name)
  {
    name:,
    line_count: content.split("\n").count,
    word_count: content.split(/\s+/).count,
    char_count: content.bytesize,
    error_message: nil
  }
end

def directory_data(name)
  {
    name:,
    line_count: 0,
    word_count: 0,
    char_count: 0,
    error_message: nil
  }
end

def create_error_messages(file_path)
  {
    name: nil,
    line_count: nil,
    word_count: nil,
    char_count: nil,
    error_message: "wc: #{file_path}: そのようなファイルやディレクトリはありません"
  }
end

def create_sum_data(count_data)
  {
    name: '合計',
    line_count: count_data.sum { |data| data[:line_count] || 0 },
    word_count: count_data.sum { |data| data[:word_count] || 0 },
    char_count: count_data.sum { |data| data[:char_count] || 0 },
    error_message: nil
  }
end

def calculate_length(file_paths, count_data)
  contains_directory = file_paths.any? { |file_path| File.directory?(file_path) }
  length = count_data[:char_count].to_s.length
  contains_directory || $stdin && length < 7 ? 7 : length
end

def format_count_data(length, file_data, options)
  return file_data[:error_message] if file_data[:error_message]

  name = file_data[:name]
  count_data_list = []
  count_data_list << file_data[:line_count] if options[:line]
  count_data_list << file_data[:word_count] if options[:word]
  count_data_list << file_data[:char_count] if options[:char]
  count_data_list = count_data_list.map { |data| data.to_s.rjust(length) }
  return count_data_list.join(' ') unless name

  File.directory?(name) ? create_directory_message(name) + [count_data_list, name].join(' ') : [count_data_list, name].join(' ')
end

def create_directory_message(directory_name)
  "wc: #{directory_name}: ディレクトリです\n"
end

main
