require 'droplet_kit'
require 'open3'

class PuzzlesController < ApplicationController
  before_action :set_puzzle, only: [:show, :edit, :update, :destroy]

  # GET /puzzles
  # GET /puzzles.json
  def index
    @puzzles = Puzzle.all
  end

  # GET /puzzles/1
  # GET /puzzles/1.json
  def show
  end

  # GET /puzzles/new
  def new
    @puzzle = Puzzle.new
  end

  # GET /puzzles/1/edit
  def edit
  end

  def run
    @puzzle = Puzzle.find(params[:id])
    client = DropletKit::Client.new(access_token: ENV['DO_TOKEN'], user_agent: 'custom')
    my_ssh_keys = client.ssh_keys.all.collect {|key| key.fingerprint}
    name = @puzzle.title.gsub(' ', '-').downcase
    @droplet = client.droplets.all.find {|d| d.name == name}
    unless @droplet
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
          "id:#{SecureRandom.base36(30)}"
          
        ]
      )
      client.droplets.create(@droplet)
    end
    @droplet = client.droplets.all.find {|d| d.name == name}
    raise "no droplet" unless @droplet
    start_gotty(@droplet)
    @identifier = identifier(@droplet)
  end

  # POST /puzzles
  # POST /puzzles.json
  def create
    @puzzle = Puzzle.new(puzzle_params)

    respond_to do |format|
      if @puzzle.save
        format.html { redirect_to @puzzle, notice: 'Puzzle was successfully created.' }
        format.json { render :show, status: :created, location: @puzzle }
      else
        format.html { render :new }
        format.json { render json: @puzzle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /puzzles/1
  # PATCH/PUT /puzzles/1.json
  def update
    respond_to do |format|
      if @puzzle.update(puzzle_params)
        format.html { redirect_to @puzzle, notice: 'Puzzle was successfully updated.' }
        format.json { render :show, status: :ok, location: @puzzle }
      else
        format.html { render :edit }
        format.json { render json: @puzzle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /puzzles/1
  # DELETE /puzzles/1.json
  def destroy
    @puzzle.destroy
    respond_to do |format|
      format.html { redirect_to puzzles_url, notice: 'Puzzle was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_puzzle
      @puzzle = Puzzle.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def puzzle_params
      params.require(:puzzle).permit(:title, :cloud_init)
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
