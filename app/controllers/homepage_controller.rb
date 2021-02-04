class HomepageController < ApplicationController
  def index
    @puzzles = Puzzle.published_puzzles
  end

  def admin
    redirect_to '/' unless current_user.admin?
    @sessions = Session.all
    @puzzles = Puzzle.all
  end
end
