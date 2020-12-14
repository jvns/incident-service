class HomepageController < ApplicationController
  def index
    @puzzles = Puzzle.all
  end

  def admin
    @instances = VmInstance.where.not(status: :terminated).all
  end
end
