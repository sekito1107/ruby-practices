#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(shot_scores)
    @frames = []

    shot_scores.gsub('X', '10').split(',').each do |shot_score|
      apply_bonus(shot_score.to_i)
      frame = create_frame_data(shot_score.to_i)
      @frames << frame if frame
    end
  end

  def score
    @frames.sum(&:frame_score)
  end

  private

  def create_frame_data(shot_score)
    frame = Frame.new(0) if @frames.empty?
    frame ||= @frames.last.finished? ? Frame.new(@frames.size) : @frames.last
    frame.record_shot(shot_score)
    frame if frame.shot_scores.size == 1
  end

  def apply_bonus(shot_score)
    @frames.each do |frame|
      frame.add_bonus(shot_score)
    end
  end
end

game = Game.new(ARGV[0])
puts game.score
