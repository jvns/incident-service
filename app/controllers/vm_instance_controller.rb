require 'open3'
class VmInstanceController < ApplicationController
  prepend_before_filter :require_no_authentication, only: [ :show_all ]
  def show
    puzzle = Puzzle.find(params[:puzzle_id])
    @instance = VmInstance.find_by(puzzle_id: puzzle.id, status: :running)
    if @instance.nil?
      @instance = create_instance(puzzle)
    end
    start_gotty(@instance)
  end

  def create
    puzzle = Puzzle.find(params[:puzzle_id])
    create_instance(puzzle)
  end

  def show_all
    return unless request.local? 

    instances = VmInstance.where(status: :running)
    result = instances.map { |instance| [instance.proxy_id, instance.gotty_port] }.to_a
    render :json => result
  end

  private

  def create_instance(puzzle)
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
    start_gotty(droplet, port)
    instance
  end


  def do_client
    @client ||= DropletKit::Client.new(access_token: ENV['DO_TOKEN'], user_agent: 'custom')
  end

  def ip_address(droplet)
    droplet.networks.v4.find{|x| x.type == 'public'}.ip_address
  end

  def gotty_running?(droplet)
    ip = ip_address(droplet)
    gotty_process = `ps aux`.split("\n").find do |x| 
      x.include?('gotty') and x.include?(ip)
    end
    !gotty_process.nil?
  end

  def start_gotty(instance)
    droplet = do_client.droplets.find(id: instance.digitalocean_id)
    if gotty_running?(droplet)
      puts "gotty is already running, not starting another one"
      return
    else
      _, _, _, thread = Open3.popen3("./gotty", "-w", "-ws-origin", "https://debugging-school-test2.jvns.ca", "-p", instance.gotty_port.to_s, "ssh", "-i", "wizard.key", "wizard@#{ip_address(droplet)}")
    end
  end
end
