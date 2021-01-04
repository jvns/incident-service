class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    raise 'only local allowed' unless request.local? || request.remote_ip.start_with?('172')
    sessions = Session.where(status: :running)

    result = sessions.map { |session| [session.proxy_id, session.gotty_port] }.to_h
    render :json => result 
  end

  def show
    load_session
    @session.droplet.start_gotty!
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: {status: @session.droplet.status} }
    end
  end

  def new
    build_session
  end

  def create
    build_session
    save_session or render 'new'
  end

  def edit
    load_session
    build_session
  end

  def update
    load_session
    build_session
    save_session or render 'edit'
  end

  def destroy
    load_session
    @session.destroy
    redirect_to '/admin'
  end

  private

  def load_sessions
    @sessions ||= session_scope.to_a
  end

  def load_session
    @session ||= session_scope.find(params[:id])
  end

  def build_session
    @session ||= session_scope.build
    @session.attributes = session_params
    @session.user_id = @current_user.id
  end

  def save_session
    if @session.save
      redirect_to @session
    end
  end

  def session_params
    session_params = params
    session_params ? session_params.permit(:puzzle_id) : {}
  end

  def session_scope
    Session.where(user_id: current_user.id)
  end
end
