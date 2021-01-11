class Session < ApplicationRecord
  enum status: [:terminated, :running, :waiting_for_ssh, :waiting_for_cloud_init]

  before_create :launch_droplet
  before_destroy :destroy_droplet

  def droplet
    Droplet.new(self)
  end

  def puzzle
    Puzzle.find(self.puzzle_id)
  end

  private

  def launch_droplet
    digitalocean_id = droplet.launch!
    self.assign_attributes(
      digitalocean_id: digitalocean_id,
      gotty_port: port = SecureRandom.rand(2000..5000),
      proxy_id: SecureRandom.base36(30),
      status: :waiting_for_ssh,
    )
  end

  def destroy_droplet
    droplet.destroy!
  end

  belongs_to :user
end
