require 'open3'
class Droplet
  def initialize(session)
    @session = session
  end
  attr_accessor :session

  def self.from_puzzle(puzzle, user)
    session = Session.where(puzzle_id: puzzle.id, user_id: user.id).first
    Droplet.new(session)
  end


  # copied from https://stackoverflow.com/questions/3386233/how-to-get-exit-status-with-rubys-netssh-library
  def ssh_exec!(ssh, command)
    stdout_data = ""
    stderr_data = ""
    exit_code = nil
    exit_signal = nil
    ssh.open_channel do |channel|
      channel.exec(command) do |ch, success|
        unless success
          return [nil, nil, -1, nil]
        end
        channel.on_data do |ch,data|
          stdout_data+=data
        end

        channel.on_extended_data do |ch,type,data|
          stderr_data+=data
        end

        channel.on_request("exit-status") do |ch,data|
          exit_code = data.read_long
        end

        channel.on_request("exit-signal") do |ch, data|
          exit_signal = data.read_long
        end
      end
    end
    ssh.loop
    [stdout_data, stderr_data, exit_code, exit_signal]
  end
  def ssh_connection
    @sess ||= Net::SSH.start(ip_address, 'wizard', :keys => [ "wizard.key" ], timeout: 0.2)
  end

  def status
    return nil unless session
    if session.waiting_for_ssh?
      begin
        ssh_connection
        session.waiting_for_cloud_init!
      rescue Errno::ECONNREFUSED 
        # keep waiting for ssh to come up!
      rescue Net::SSH::ConnectionTimeout
        # keep waiting for ssh to come up!
      rescue Errno::EADDRNOTAVAIL
        # keep waiting for ssh to come up!
      end
    end
    if session.waiting_for_cloud_init?
        _, _, exit_code, _ = ssh_exec!(ssh_connection, '/usr/local/bin/started_up')
        if exit_code == 0
          session.running!
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
    end
    @droplet
  end

  def destroy!
    begin
      do_client.droplets.delete(id: session.digitalocean_id)
    rescue DropletKit::Error
      # probably a 404 because that resource doesn't exist, ignore
    end
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
      if ENV['RAILS_ENV'] == 'development'
        url = "https://exploding-puzzles-test.ngrok.io"
      else
        url = "https://exploding-computers.jvns.ca"
      end
      _, _, _, thread = Open3.popen3("./gotty", "-w", "-ws-origin", url, "-p", session.gotty_port.to_s, "ssh", "-i", "wizard.key", "wizard@#{ip_address}")
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
      # TODO: this throws exceptions sometimes, we're just ignoring them for now
      begin
        x.include?('gotty') and x.include?(ip_address)
      rescue
      end
    end
    !gotty_process.nil?
  end

  def do_client
    @client ||= DropletKit::Client.new(access_token: ENV['DO_TOKEN'], user_agent: 'custom')
  end
end
