#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'frame'
require 'debug'

class Game
  def initialize(shot_scores)
    @frames = []

    shot_scores.gsub('X', '10').split(',').each do |shot_score|
      frame = record_shot(shot_score.to_i)
      frame.finished? ? @frames << frame : @tmp_frame = frame
    end
  end

  def score
    @frames.sum(&:frame_score)
  end

  private

  def record_shot(shot_score)
    apply_bonus(shot_score)
    frame = @tmp_frame.nil? ? Frame.new(@frames.size || 0) : @tmp_frame
    frame.record_shot(shot_score)
    @tmp_frame = nil if frame.finished?
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
