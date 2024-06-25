#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'frame'

class Game
  def self.calc_score(shot_scores)
    frames = []
    shot_scores.split(',').each do |shot_score|
      frames << Frame.new(frames.size) if frames.empty? || frames.last.finished?
      frames.each do |frame|
        frame.record_shot(shot_score)
      end
    end
    frames.sum(&:frame_score)
  end
end

puts Game.calc_score(ARGV[0])
