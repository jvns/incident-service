require 'open3'
require 'net/http'

class Fly
  def initialize(session)
    @session = session
  end
  attr_accessor :session

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
    @sess ||= Net::SSH.start(ip_address,
                             'wizard', 
                             port: 23,
                             keys: [ "wizard.key" ],
                             timeout: 0.2)
  end

  def status
    return nil unless session
    if session.waiting_for_ssh?
      begin
        ssh_connection
        session.running!
      #rescue Errno::ECONNREFUSED 
      #  puts "connection refused to #{ip_address}"
      #  # keep waiting for ssh to come up!
      rescue Net::SSH::ConnectionTimeout
        puts "connection timeout"
        # keep waiting for ssh to come up!
      rescue Errno::EADDRNOTAVAIL
        puts "addr not avail"
        # keep waiting for ssh to come up!
        # I don't understand why this error happens, need to look into it at some point
      end
    end
    session.status
  end

  def launch!
    name = "puzzle-#{SecureRandom.hex}"
    job1 = fork do
      exec "./fly-api-fun/fly-fun #{name}"
    end

    Process.detach(job1)
    if ENV['RAILS_ENV'] == 'production'
      @session.ip_address = "#{name}.internal"
    else
      @session.ip_address = "#{name}.fly.dev"
    end
    name
  end

  def destroy!
  end

  def ip_address
    @session.ip_address
  end
end