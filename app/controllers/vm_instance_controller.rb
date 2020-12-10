class VmInstanceController < ApplicationController
  def show
    puzzle = Puzzle.find(params[:id])
  end

  def show_all
  end

  def create(puzzle)
    my_ssh_keys = do_client.ssh_keys.all.collect {|key| key.fingerprint}
    name = puzzle.title.gsub(' ', '-').downcase
    @droplet = client.droplets.all.find {|d| d.name == name}
    proxy_id = SecureRandom.base36(30)
    @droplet = DropletKit::Droplet.new(
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
        "proxy_id:#{proxy_id}"

      ]
    )
    VmInstance.create(
      digitalocean_id: @droplet.id,
      user_email: current_user.email,
      proxy_id: proxy_id,
    )
    start_gotty(@droplet)
    @identifier = identifier(@droplet)
  end

  private

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

  def start_gotty(droplet)
    if gotty_running?(droplet)
      puts "gotty is already running, not starting another one"
      return
    else
      port = SecureRandom.rand(2000..5000)
      _, _, _, thread = Open3.popen3("./gotty", "-w", "-ws-origin", "https://debugging-school-test2.jvns.ca", "-p", port.to_s, "ssh", "-i", "wizard.key", "wizard@#{ip_address(droplet)}")
      save_port_mapping(droplet, port)
    end
  end
  def identifier(droplet)
    droplet.tags.find {|x| x.include?('id:')}.split(':')[1]
  end

  def save_port_mapping(droplet, port)
    File.open("mapping.json","w+") do |f|
      # todo: read the file first, or store the data in a db, or something.
      # this is no good.
      mapping = {}
      mapping[identifier(droplet)] = port
      f.write(mapping.to_json)
    end
  end


end
