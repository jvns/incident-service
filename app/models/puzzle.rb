class Puzzle < ApplicationRecord
  def to_param
    "#{id}-#{title.parameterize}"
  end

  def finished?(user)
    puzzle_statuses.where(user_id: user.id).first&.finished || false
  end
  has_many :puzzle_statuses, dependent: :destroy 
end
