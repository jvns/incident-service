class HomepageController < ApplicationController
  def index
    @puzzles = Puzzle.all
  end

  def admin
    redirect_to '/' unless current_user.admin?
    @sessions = Session.all
    @puzzles = Puzzle.all
  end
end
