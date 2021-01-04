class HomepageController < ApplicationController
  def index
    @puzzles = Puzzle.all
  end

  def admin
    redirect_to '/' unless current_user.admin?
    @instances = Session.where.not(status: :terminated).all
    @puzzles = Puzzle.all
  end
end
