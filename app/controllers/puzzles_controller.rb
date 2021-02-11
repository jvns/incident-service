require 'droplet_kit'
require 'open3'

class PuzzlesController < ApplicationController
  # GET /puzzles
  # GET /puzzles.json
  def index
    @puzzles = Puzzle.published_puzzles
  end

  # GET /puzzles/1
  # GET /puzzles/1.json
  def show
    load_puzzle
    @session = Session.from_puzzle(@puzzle, current_user)
  end

  def success
    load_puzzle
    guess = params[:password]
    unless guess.include?(@puzzle.password)
      redirect_to @puzzle, notice: "Oops, that's not quite right!"
    end
    PuzzleStatus.create(user_id: current_user.id, puzzle_id: @puzzle.id, finished: true)
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
