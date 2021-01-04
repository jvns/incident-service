require 'open3'
class Droplet
  def initialize(session)
    @session = session
  end
  attr_accessor :session

  def self.from_puzzle(puzzle, user)
    session = Session.where(puzzle_id: puzzle.id, user_id: user.id).where.not( status: :terminated).first
    Droplet.new(session)
  end

  def status
    return nil unless session
    if ip_address.nil?
      session.terminated!
    elsif session.pending?
      begin
        sess = Net::SSH.start(ip_address, 'wizard', :keys => [ "wizard.key" ], timeout: 0.2)
        sess.exec!('ls')
        session.waiting_for_start_script!
        sess.exec!('sudo bash files/run.sh')
        sess.exec!('sudo rm files/run.sh')
        session.running!
      rescue Errno::ECONNREFUSED 
        # probably the session just didn't start yet, let's continue to say it's pending
      rescue Net::SSH::ConnectionTimeout
        # probably the session just didn't start yet, let's continue to say it's pending
      end
    end
    if session.running?
      start_gotty!
    end
    session.status
  end

  def droplet
    return unless session
    begin
      @droplet ||= do_client.droplets.find(id: session.digitalocean_id)
    rescue 
      # let's assume it was a 404 exception and the session just wasn't found
      # todo: should do something better, what if it's not a 404?
      session.terminated!
    end
    @droplet
  end

  def destroy!
    do_client.droplets.delete(id: session.digitalocean_id)
  end

  def launch!
    my_ssh_keys = do_client.ssh_keys.all.collect {|key| key.fingerprint}
    name = session.puzzle.title.downcase.gsub(/[^a-z0-9]/, '-') + SecureRandom.base36(10)
    droplet = DropletKit::Droplet.new(
      name: name,
      region: 'nyc3',
      size: "s-1vcpu-1gb",
      ssh_keys: my_ssh_keys,
      image: "ubuntu-20-04-x64",
      backups: false,
      ipv6: true,
      user_data: session.puzzle.cloud_init,
      tags: [
        "debugging-school" # TODO: maybe add more tags here
      ]
    )
    # reset droplet to be the version from the API
    droplet = do_client.droplets.create(droplet)
    droplet.id
  end

  def start_gotty!
    if gotty_running?
      puts "gotty is already running, not starting another one"
      return
    else
      _, _, _, thread = Open3.popen3("./gotty", "-w", "-ws-origin", "https://exploding-computers.jvns.ca", "-p", session.gotty_port.to_s, "ssh", "-i", "wizard.key", "wizard@#{ip_address}")
    end
  end

  def ip_address
    begin
      droplet.networks.v4.find{|x| x.type == 'public'}.ip_address
    rescue
      # todo: maybe improve error handling here?
    end
    
  end

  private

  def gotty_running?
    gotty_process = `ps aux`.split("\n").find do |x| 
      x.include?('gotty') and x.include?(ip_address)
    end
    !gotty_process.nil?
  end

  def do_client
    @client ||= DropletKit::Client.new(access_token: ENV['DO_TOKEN'], user_agent: 'custom')
  end
end
