# frozen_string_literal: true

class Frame
  attr_reader :frame_number, :shot_scores

  def initialize(frame_number)
    @frame_number = frame_number
    @shot_scores = []
    @bonus_scores = []
  end

  def record_shot(shot_score)
    @bonus_scores << shot_score if (strike? && @bonus_scores.size < 2 || spare? && @bonus_scores.empty?) && frame_number < 9
    @shot_scores << shot_score if !finished?
  end

  def frame_score
    @shot_scores.sum + @bonus_scores.sum
  end

  def finished?
    (@shot_scores.size == 2 || strike?) && @frame_number <= 8
  end

  private

  def strike?
    @shot_scores[0] == 10
  end

  def spare?
    !strike? && @shot_scores.sum == 10
  end
end
