class VmInstance < ApplicationRecord
  enum status: [:terminated, :running, :starting]
end
