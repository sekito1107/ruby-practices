#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'frame'

class Game
  def self.calc_score(shots)
    frames = []
    shots.split(',').each do |shot|
      frames << Frame.new(frames.size) if frames.empty? || frames.last.finished?
      frames.each do |frame|
        frame.record_shot(shot)
      end
    end
    frames.sum(&:calc_score)
  end
end

puts Game.calc_score(ARGV[0])
