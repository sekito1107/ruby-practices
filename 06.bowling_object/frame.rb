# frozen_string_literal: true

class Frame
  def initialize(frame_number)
    @frame_number = frame_number
    @shots = []
    @bonus_shots = []
  end

  def record_shot(shot_score)
    score = shot_score == 'X' ? 10 : shot_score.to_i
    @bonus_shots << score if need_bonus?
    @shots << score unless finished?
  end

  def calc_score
    @shots.sum + @bonus_shots.sum
  end

  def finished?
    (@shots.size == 2 || strike?) && @frame_number <= 8
  end

  private

  def strike?
    @shots[0] == 10
  end

  def spare?
    !strike? && @shots.sum == 10
  end

  def need_bonus?
    (strike? && @bonus_shots.size < 2 || spare? && @bonus_shots.empty?) && @frame_number < 9
  end
end
