#!/usr/bin/env ruby
# frozen_string_literal: true

LAST_FLAME = 10

points = ARGV[0].gsub('X', '10').split(',').map(&:to_i)

score = 0
shot = 0
flame = 1
previous_point = 0

points.each_with_index do |point, index|
  shot += 1
  if flame == LAST_FLAME
    score += point
  else
    strike = point == 10 && shot == 1
    spare = previous_point + point == 10
    if strike
      score += 10 + points[index + 1, 2].sum
    elsif spare
      score += 10 + points[index + 1]
    elsif shot == 2
      score += previous_point + point
    end

    if shot == 2 || strike
      flame += 1
      shot = 0
      previous_point = 0
    else
      previous_point = point
    end
  end
end

puts score
