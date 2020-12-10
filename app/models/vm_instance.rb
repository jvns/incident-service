class VmInstance < ApplicationRecord
  enum status: [:terminated, :running, :pending]

end
