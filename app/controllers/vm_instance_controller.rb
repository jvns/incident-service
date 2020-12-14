require 'open3'
class VmInstanceController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    raise 'only local allowed' unless request.local?
    instances = VmInstance.where(status: :running)
    result = instances.map { |instance| [instance.proxy_id, instance.gotty_port] }.to_h
    render :json => result 
  end

  def create
    puzzle = Puzzle.find(params[:puzzle_id])
    droplet = Droplet.from_puzzle(puzzle, current_user)
    droplet.launch
    redirect_to "/puzzles/#{puzzle.id}/"
  end

  def status
    instance = instance_scope.find_by(digitalocean_id: params[:digitalocean_id])
    droplet = Droplet.from_instance(instance)
    render :json => {status: droplet.status} 
  end

  def destroy
    instance = instance_scope.find_by(digitalocean_id: params[:digitalocean_id])
    puzzle = Puzzle.find(instance.puzzle_id)
    droplet = Droplet.from_instance(instance)
    droplet.destroy!
    redirect_to '/admin'
  end

  private

  def instance_scope
    VmInstance.where(user_id: current_user.id)
  end
  
end
