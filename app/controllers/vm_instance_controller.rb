require 'open3'
class VmInstanceController < ApplicationController
  skip_before_action :authenticate_user!, only: :show_all_json
  def show
    puzzle = Puzzle.find(params[:puzzle_id])
    @instance = Droplet.from_puzzle(puzzle, current_user).instance
    redirect_to puzzle if @instance.nil?
  end

  def create
    puzzle = Puzzle.find(params[:puzzle_id])
    droplet = Droplet.from_puzzle(puzzle, current_user)
    droplet.launch
    redirect_to "/puzzles/#{puzzle.id}/play"
  end

  def status
    instance = VmInstance.find_by(digitalocean_id: params[:digitalocean_id])
    droplet = Droplet.from_instance(instance)
    if droplet.ip_address.nil?
      instance.terminated!
    else
      begin
        sess = Net::SSH.start(droplet.ip_address, 'wizard', :keys => [ "wizard.key" ], timeout: 0.2)
        sess.exec!('ls')
        instance.running!
      rescue Net::SSH::ConnectionTimeout
        # probably the instance just didn't start yet, let's say it's pending
        instance.pending!
      end
    end
    render :json => {status: instance.status} 
  end

  def destroy
    instance = VmInstance.find_by(digitalocean_id: params[:digitalocean_id])
    puzzle = Puzzle.find(instance.puzzle_id)
    droplet = Droplet.from_instance(instance)
    droplet.destroy!
    instance.terminated!
    redirect_to puzzle
  end

  def show_all_json
    raise 'only local allowed' unless request.local?
    instances = VmInstance.where(status: :running)
    result = instances.map { |instance| [instance.proxy_id, instance.gotty_port] }.to_h
    render :json => result 
  end
end
