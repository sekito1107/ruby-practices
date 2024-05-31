#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'frame'

class Game
  attr_reader :score_board

  def initialize
    @frames = [Frame.new(1)]
    @special_frames = []
    @score_board = ARGV[0].gsub('X', '10').split(',').map(&:to_i)
  end

  def record_shot(pins)
    calc_bonus(pins)
    frame = @frames.last
    frame.record_shot(pins)
    return if frame.last_frame?

    @frames << Frame.new(@frames.size + 1) if frame.finished?
    @special_frames << frame if frame.strike? || frame.spare?
  end

  def score
    result = 0
    @frames.each do |frame|
      result += frame.score
    end
    result
  end

  private

  def calc_bonus(pins)
    @special_frames.each do |special_frame|
      special_frame.add_bonus(pins) if special_frame.need_bonus?
    end
  end
end

game = Game.new
game.score_board.each do |shot_pins|
  game.record_shot(shot_pins)
end
puts game.score
