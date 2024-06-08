#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(shot_scores)
    @frames = [Frame.new(0)]
    @special_frames = []

    scores.gsub('X', '10').split(',').map(&:to_i).each do |shot_score|
      record_shot(shot_score)
    end
  end

  def record_shot(shot_score)
    calc_bonus(shot_score)
    frame = @frames.last
    frame.record_shot(shot_score)
    return if frame.last_frame?

    @frames << Frame.new(@frames.size) if frame.finished?
    @special_frames << frame if frame.strike? || frame.spare?
  end

  def score
    @frames.sum(&:score)
  end

  private

  def calc_bonus(shot_score)
    @special_frames.each do |special_frame|
      special_frame.add_bonus(shot_score) if special_frame.need_bonus?
    end
  end
end

game = Game.new(ARGV[0])
puts game.score
