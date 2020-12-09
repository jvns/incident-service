class Puzzle < ApplicationRecord
  def to_param
    "#{id}-#{title.parameterize}"
  end
end
