class Session < ApplicationRecord
  enum status: [:terminated, :running, :pending, :waiting_for_start_script]

  before_create :launch_droplet
  before_destroy :destroy_droplet

  private

  def launch_droplet
    droplet = Droplet.from_puzzle(Puzzle.find(self.puzzle_id), User.find(self.user_id))
    digitalocean_id = droplet.launch!
    self.assign_attributes(
      digitalocean_id: digitalocean_id,
      gotty_port: port = SecureRandom.rand(2000..5000),
      proxy_id: SecureRandom.base36(30),
      status: :pending,
      
    )
  end

  def destroy_droplet
    droplet = Droplet.from_session(self)
    droplet.destroy!
  end

  belongs_to :puzzle
  belongs_to :user
end
