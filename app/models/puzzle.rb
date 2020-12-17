class Puzzle < ApplicationRecord
  def to_param
    "#{id}-#{title.parameterize}"
  end
  has_many :puzzle_statuses
end
