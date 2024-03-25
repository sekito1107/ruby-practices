#!/usr/bin/env ruby
# frozen_string_literal: true

# スコアを計算しやすいように整える
points = ARGV[0].split(',')
points.map! { |point| point.gsub('X', '10').to_i }
# 必要な変数を定義する
score = 0
shot = 0
flame = 1
previous_point = 0
last_flame = 10
# スコアを計算
points.each_with_index do |point, index|
  shot += 1
  if flame != last_flame
    if point == 10 && shot == 1
      score += 10 + points[index.next] + points[index.next.next]
      shot += 1
    elsif previous_point + point == 10
      score += 10 + points[index.next]
    elsif shot == 2
      score += previous_point + point
    else
      previous_point = point
    end
    if shot == 2
      flame += 1
      shot = 0
      previous_point = 0
      next
    end
  end
  score += point if flame == last_flame
end

puts score
