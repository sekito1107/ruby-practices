#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  options, file_paths = fetch_options!(ARGV)
  count_deta = file_paths.empty? ? count_stdin($stdin) : count_files(file_paths, file_paths.size > 1)
  return if count_deta.empty?

  length = calculate_length(file_paths, count_deta[-1]) if count_deta
  puts(count_deta.map { |deta| format_count_deta(length, deta, options) })
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
  [create_count_deta(content.read, nil)]
end

def count_files(file_paths, multiple_files)
  count_deta = file_paths.map do |file_path|
    if File.file?(file_path)
      create_count_deta(File.read(file_path), file_path)
    elsif File.directory?(file_path)
      dammy_deta(file_path)
    else
      create_error_messages(file_path)
    end
  end
  count_deta << create_sum_deta(count_deta.compact) if multiple_files
  count_deta.compact
end

def create_count_deta(content, name)
  {
    name:,
    line_count: content.split("\n").count,
    word_count: content.split(/\s+/).count,
    char_count: content.bytesize,
    error_message: nil
  }
end

def dammy_deta(name)
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

def create_sum_deta(count_deta)
  {
    name: '合計',
    line_count: count_deta.sum { |deta| deta[:line_count] || 0 },
    word_count: count_deta.sum { |deta| deta[:word_count] || 0 },
    char_count: count_deta.sum { |deta| deta[:char_count] || 0 },
    error_message: nil
  }
end

def calculate_length(file_paths, count_deta)
  contains_directory = file_paths.any? { |file_path| File.directory?(file_path) }
  length = count_deta[:char_count].to_s.length
  contains_directory || $stdin && length < 7 ? 7 : length
end

def format_count_deta(length, file_deta, options)
  return file_deta[:error_message] if file_deta[:error_message]

  name = file_deta[:name]
  count_deta_list = []
  count_deta_list << file_deta[:line_count] if options[:line]
  count_deta_list << file_deta[:word_count] if options[:word]
  count_deta_list << file_deta[:char_count] if options[:char]
  count_deta_list = count_deta_list.map { |deta| deta.to_s.rjust(length) }
  return count_deta_list.join(' ') unless name

  File.directory?(name) ? create_directory_message(name) + [count_deta_list, name].join(' ') : [count_deta_list, name].join(' ')
end

def create_directory_message(directory_name)
  "wc: #{directory_name}: ディレクトリです\n"
end

main
