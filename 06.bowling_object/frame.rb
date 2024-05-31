# frozen_string_literal: true

class Frame
  def initialize(frame_number)
    @frame_number = frame_number
    @score = 0
    @bonus = 0
    @shot_count = 0
    @bonus_count = 0
  end

  def record_shot(pins)
    @score += pins
    @shot_count += 1
  end

  def strike?
    @shot_count == 1 && @score == 10
  end

  def spare?
    @shot_count == 2 && @score == 10
  end

  def finished?
    @shot_count == 2 || @score == 10
  end

  def score
    @score + @bonus
  end

  def need_bonus?
    if strike?
      @bonus_count < 2
    elsif spare?
      @bonus_count < 1
    end
  end

  def add_bonus(pins)
    @bonus += pins
    @bonus_count += 1
  end

  def last_frame?
    @frame_number == 9
  end
end
