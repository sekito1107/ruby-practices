#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(shot_scores)
    @frames = [Frame.new(0)]

    shot_scores.gsub('X', '10').split(',').map(&:to_i).each do |shot_score|
      record_shot(shot_score)
    end
  end

  def score
    @frames.sum(&:score)
  end

  private

  def record_shot(shot_score)
    apply_bonus(shot_score)
    frame = @frames.last
    frame.record_shot(shot_score)
    @frames << Frame.new(@frames.size) if frame.finished?
  end

  def apply_bonus(shot_score)
    @frames.take(9).each do |frame| # ボーナスが適用されるのは9フレーム目まで
      frame.add_bonus(shot_score)
    end
  end
end

game = Game.new(ARGV[0])
puts game.score
