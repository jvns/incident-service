class VmInstance < ApplicationRecord
  enum status: [:terminated, :running, :pending, :waiting_for_start_script]

end
