#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(shot_scores)
    @frames = [Frame.new(0)]

    shot_scores.gsub('X', '10').split(',').each do |shot_score|
      apply_bonus(shot_score.to_i)
      frame = create_frame_data(shot_score.to_i)
      frame.finished? ? @frames[frame.frame_number] = frame : @frames << frame
    end
  end

  def score
    @frames.sum(&:frame_score)
  end

  private

  def create_frame_data(shot_score)
    frame = @frames.last.finished? ? Frame.new(@frames.size) : @frames.last
    frame.record_shot(shot_score)
    frame
  end

  def apply_bonus(shot_score)
    @frames.each do |frame|
      frame.add_bonus(shot_score) if frame.frame_number < 9
    end
  end
end

game = Game.new(ARGV[0])
puts game.score
