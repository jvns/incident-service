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
    droplet = Droplet.from_puzzle(puzzle, current_user)
    droplet.launch
    redirect_to '/'
  end

  def destroy
    instance = VmInstance.find(params[:digitalocean_id])
    droplet = Droplet.from_instance(instance)
    droplet.destroy!
  end

  def show_all_json
    raise 'only local allowed' unless request.local?
    instances = VmInstance.where(status: :running)
    result = instances.map { |instance| [instance.proxy_id, instance.gotty_port] }.to_h
    render :json => result 
  end
end
