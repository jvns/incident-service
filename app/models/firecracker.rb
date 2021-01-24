require 'open3'
require 'net/http'

class Firecracker
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
    @sess ||= Net::SSH.start(ip_address, 'wizard', :keys => [ "wizard.key" ], timeout: 0.2)
  end

  def status
    return nil unless session
    if session.waiting_for_ssh?
      begin
        ssh_connection
        session.running!
      rescue Errno::ECONNREFUSED 
        # keep waiting for ssh to come up!
      rescue Net::SSH::ConnectionTimeout
        # keep waiting for ssh to come up!
      rescue Errno::EADDRNOTAVAIL
        # keep waiting for ssh to come up!
        # I don't understand why this error happens, need to look into it at some point
      end
    end
    session.status
  end

  def launch!
    uri = URI("http://host:8080/create")
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = {
      root_image_path: '/images/base.ext4',
      kernel_path: '/images/vmlinux-5.8'
    }.to_json
    resp = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    resp = JSON.parse(resp.body)
    @session.ip_address = resp['ip_address']
    resp['id']
  end

  def destroy!
    uri = URI("http://host:8080")
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = {
      id: @session.vm_id
    }.to_json
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
  end

  def ip_address
    @session.ip_address
  end
end