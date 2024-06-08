#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(scores)
    @frames = [Frame.new(0)]
    @special_frames = []
    @score_board = scores.gsub('X', '10').split(',').map(&:to_i)

    @score_board.each do |shot_pin|
      record_shot(shot_pin)
    end
  end

  def record_shot(pin)
    calc_bonus(pin)
    frame = @frames.last
    frame.record_shot(pin)
    return if frame.last_frame?

    @frames << Frame.new(@frames.size) if frame.finished?
    @special_frames << frame if frame.strike? || frame.spare?
  end

  def score
    @frames.sum(&:score)
  end

  private

  def calc_bonus(pin)
    @special_frames.each do |special_frame|
      special_frame.add_bonus(pin) if special_frame.need_bonus?
    end
  end
end

game = Game.new(ARGV[0])
puts game.score
