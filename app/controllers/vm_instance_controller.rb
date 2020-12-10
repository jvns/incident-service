require 'open3'
class VmInstanceController < ApplicationController
  skip_before_action :authenticate_user!, only: :show_all_json
  def show
    puzzle = Puzzle.find(params[:puzzle_id])
    @instance = VMInstance.running_instance(puzzle)
    redirect_to puzzle if @instance.nil?
  end

  def create
    puzzle = Puzzle.find(params[:puzzle_id])
    instance = VmInstance.launch(puzzle)
    start_gotty(instance)
  end

  def destroy
    instance = VmInstance.find(params[:digitalocean_id])
  end

  def show_all_json
    raise 'only local allowed' unless request.local?
    instances = VmInstance.where(status: :running)
    result = instances.map { |instance| [instance.proxy_id, instance.gotty_port] }.to_h
    render :json => result 
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

  def get_droplet(instance)
    begin
      do_client.droplets.find(id: instance.digitalocean_id)
    rescue
      # let's assume it was a 404 exception and the instance just wasn't found
      # todo: should do something better
    end
  end

  def start_gotty(instance)
    droplet = get_droplet(instance)
    if gotty_running?(droplet)
      puts "gotty is already running, not starting another one"
      return
    else
      _, _, _, thread = Open3.popen3("./gotty", "-w", "-ws-origin", "https://debugging-school-test2.jvns.ca", "-p", instance.gotty_port.to_s, "ssh", "-i", "wizard.key", "wizard@#{ip_address(droplet)}")
    end
  end
end
