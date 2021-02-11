class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, :all
    else
      can :manage, Puzzle, :published => true
      can :manage, Session, user_id: user.id
    end
  end
end
