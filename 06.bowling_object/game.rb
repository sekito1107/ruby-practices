#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'frame'

class Game
  def calc_score(shot_scores)
    frames = []
    shot_scores.gsub('X', '10').split(',').each do |shot_score|
      apply_bonus(frames, shot_score.to_i)
      new_frame = create_frame(frames)
      frames << new_frame if new_frame
      target_frame = frames.last
      target_frame.record_shot(shot_score.to_i)
    end
    frames.sum(&:frame_score)
  end

  private

  def create_frame(frames)
    Frame.new(frames.size) if frames.empty? || frames.last.finished?
  end

  def apply_bonus(frames, shot_score)
    frames.each do |frame|
      frame.add_bonus(shot_score)
    end
  end
end

puts Game.new.calc_score(ARGV[0])
