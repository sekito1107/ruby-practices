# frozen_string_literal: true

class Frame
  def initialize(frame_number)
    @frame_number = frame_number
    @scores = []
    @bonuses = []
  end

  def record_shot(shot_score)
    @scores << shot_score
  end

  def score
    @scores.sum + @bonuses.sum
  end

  def need_bonus?
    strike? && @bonuses.size < 2 || spare? && @bonuses.empty?
  end

  def add_bonus(shot_score)
    @bonuses << shot_score
  end

  def last_frame?
    @frame_number == 9
  end
  
  private

  def strike?
    @scores.size == 1 && @scores.sum == 10
  end

  def spare?
    @scores.size == 2 && @scores.sum == 10
  end

  def finished?
    @scores.size == 2 || @scores.sum == 10
  end
end
