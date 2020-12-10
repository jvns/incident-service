class VmInstance < ApplicationRecord
  enum status: [:terminated, :running, :pending]

  def running_instance(puzzle)
    instance = find_by(puzzle_id: puzzle.id, status: :running)
    return nil if instance.nil?
    unless get_droplet(instance)
      instance.terminated!
      return nil
    end
    instance
  end

  def launch(puzzle)
    my_ssh_keys = do_client.ssh_keys.all.collect {|key| key.fingerprint}
    name = puzzle.title.gsub(' ', '-').downcase + '-' + SecureRandom.base36(10)
    proxy_id = SecureRandom.base36(30)
    port = SecureRandom.rand(2000..5000) # TODO; this won't scale
    droplet = DropletKit::Droplet.new(
      name: name,
      region: 'nyc3',
      size: "s-1vcpu-1gb",
      ssh_keys: my_ssh_keys,
      image: "ubuntu-20-04-x64",
      backups: false,
      ipv6: true,
      user_data: puzzle.cloud_init,
      tags: [
        "debugging-school",
        "proxy_id:#{proxy_id}",
        "user:#{current_user.email}",
        "port:#{port}",
      ]
    )
    do_client.droplets.create(droplet)
    instance = VmInstance.create(
      digitalocean_id: droplet.id,
      user_id: current_user.id,
      proxy_id: proxy_id,
      gotty_port: port,
      puzzle_id: puzzle.id,
      status: :running,
    )
    instance
  end
end
