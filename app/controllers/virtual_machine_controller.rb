require 'droplet_kit'
class VirtualMachineController < ApplicationController
  before_action :connect_do

  def index
  end
  

  private
  def create(name)
  end
  def connect_do
    @client ||= DropletKit::Client.new(access_token: ENV['DO_TOKEN'], user_agent: 'custom')
  end
end
