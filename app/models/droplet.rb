class Droplet
  def initialize(puzzle, instance, user)
    @puzzle = puzzle
    @instance = instance
    @user = user
  end
  attr_accessor :instance

  def self.from_puzzle(puzzle, user)
    instance = VmInstance.find_by(puzzle_id: puzzle.id, status: :running, user_id: user.id)
    Droplet.new(puzzle, instance, user)
  end

  def self.from_instance(instance)
    puzzle = Puzzle.find(instance.puzzle_id)
    user = User.find(instance.user_id)
    Droplet.new(puzzle, instance, user)
  end

  def droplet
    return unless instance
    begin
      @droplet ||= do_client.droplets.find(id: instance.digitalocean_id)
    rescue 
      # let's assume it was a 404 exception and the instance just wasn't found
      # todo: should do something better, what if it's not a 404?
      instance.terminated!
    end
    @droplet
  end

  def destroy!
    do_client.droplets.delete(id: droplet.id.to_i)

  end

  def launch
    my_ssh_keys = do_client.ssh_keys.all.collect {|key| key.fingerprint}
    name = @puzzle.title.gsub(' ', '-').downcase + '-' + SecureRandom.base36(10)
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
      user_data: @puzzle.cloud_init,
      tags: [
        "debugging-school",
        "proxy_id:#{proxy_id}",
        "user:#{@user.email}",
        "port:#{port}",
      ]
    )
    # reset droplet to be the version from the API
    @droplet = do_client.droplets.create(droplet)
    VmInstance.create(
      digitalocean_id: @droplet.id,
      user_id: @user.id,
      proxy_id: proxy_id,
      gotty_port: port,
      puzzle_id: @puzzle.id,
      status: :running,
    )
  end

  def start_gotty
    if gotty_running?
      puts "gotty is already running, not starting another one"
      return
    else
      _, _, _, thread = Open3.popen3("./gotty", "-w", "-ws-origin", "https://debugging-school-test2.jvns.ca", "-p", instance.gotty_port.to_s, "ssh", "-i", "wizard.key", "wizard@#{ip_address}")
    end
  end

  def ip_address
    droplet.networks.v4.find{|x| x.type == 'public'}.ip_address
  end

  private

  def gotty_running
    gotty_process = `ps aux`.split("\n").find do |x| 
      x.include?('gotty') and x.include?(ip_address)
    end
    !gotty_process.nil?
  end

  def do_client
    @client ||= DropletKit::Client.new(access_token: ENV['DO_TOKEN'], user_agent: 'custom')
  end
end
