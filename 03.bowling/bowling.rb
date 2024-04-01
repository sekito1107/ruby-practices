#!/usr/bin/env ruby
# frozen_string_literal: true

points = ARGV[0].gsub('X', '10').split(',').map(&:to_i)

score = 0
shot = 0
flame = 1
previous_point = 0
LAST_FLAME = 10

points.each_with_index do |point, index|
  shot += 1
  if flame == LAST_FLAME
    score += point
  else
    if point == 10 && shot == 1
      score += 10 + points[index + 1] + points[index + 2]
      shot += 1
    elsif previous_point + point == 10
      score += 10 + points[index + 1]
    elsif shot == 2
      score += previous_point + point
      flame += 1
      shot = 0
      previous_point = 0
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
end

puts score
