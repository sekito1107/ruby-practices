# frozen_string_literal: true

class Frame
  attr_reader :frame_number

  def initialize(frame_number)
    @frame_number = frame_number
    @shot_scores = []
    @bonuses = []
  end

  def record_shot(shot_score)
    @shot_scores << shot_score
  end

  def frame_score
    @shot_scores.sum + @bonuses.sum
  end

  def add_bonus(shot_score)
    @bonuses << shot_score if strike? && @bonuses.size < 2 || spare? && @bonuses.empty?
  end

  def finished?
    (@shot_scores.size == 2 || @shot_scores.sum == 10) && @frame_number <= 9
  end

  private

  def strike?
    @shot_scores.size == 1 && @shot_scores.sum == 10
  end

  def spare?
    @shot_scores.size == 2 && @shot_scores.sum == 10
  end
end
