require 'droplet_kit'
require 'open3'

class PuzzlesController < ApplicationController
  # GET /puzzles
  # GET /puzzles.json
  def index
    @puzzles = Puzzle.all
  end

  # GET /puzzles/1
  # GET /puzzles/1.json
  def show
    load_puzzle
  end

  def finished
    load_puzzle
    PuzzleStatus.create(user_id: current_user.id, puzzle_id: @puzzle.id, finished: true)
    redirect_to '/'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def load_puzzle
      @puzzle = Puzzle.find(params[:id].to_i)
    end
end
