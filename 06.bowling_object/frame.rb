# frozen_string_literal: true

class Frame
  def initialize(frame_number)
    @frame_number = frame_number
    @score = []
    @bonus = []
  end

  def record_shot(pins)
    @score << pins
  end

  def strike?
    @score.size == 1 && @score.sum == 10
  end

  def spare?
    @score.size == 2 && @score.sum == 10
  end

  def finished?
    @score.size == 2 || @score.sum == 10
  end

  def score
    @score.sum + @bonus.sum
  end

  def need_bonus?
    strike? && @bonus.size < 2 || spare? && @bonus.empty?
  end

  def add_bonus(pins)
    @bonus << pins
  end

  def last_frame?
    @frame_number == 9
  end
end
