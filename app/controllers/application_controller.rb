class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :ensure_session

  private

  def ensure_session
    return if current_user.nil?
    return if Session.where(user_id: current_user.id).first
    # todo: this logic is duplicated from the session controller, gross
    if ENV['RAILS_ENV'] == 'production'
      vm_type = :fly
    else
      vm_type= :firecracker
    end
    Session.create(
      user_id: current_user.id,
      vm_type: vm_type,
      puzzle_id: 1, # todo: hack bc i haven't migrated the schema yet
    )

  end
end
