class Session < ApplicationRecord
  enum status: [:terminated, :running, :waiting_for_ssh, :waiting_for_cloud_init]
  enum vm_type: [:digitalocean, :firecracker, :ignite, :fly]

  before_create :launch_vm
  before_destroy :destroy_vm

  def vm
    if digitalocean?
      Droplet.new(self)
    elsif firecracker?
      Firecracker.new(self)
    elsif ignite?
      Ignite.new(self)
    elsif fly?
      Fly.new(self)
    end
  end

  def self.from_puzzle(puzzle, user)
    Session.where(puzzle_id: puzzle.id, user_id: user.id).first
  end

  def puzzle
    @puzzle ||= Puzzle.find(self.puzzle_id)
  end

  private

  def launch_vm
    vm_id = vm.launch!
    self.assign_attributes(
        vm_id: vm_id,
        # todo: delete gotty port, literally not used at all
        gotty_port: port = SecureRandom.rand(2000..5000),
        proxy_id: SecureRandom.base36(30),
        status: :waiting_for_ssh,
      )
  end

  def destroy_vm
    vm.destroy!
  end

  belongs_to :user
end
