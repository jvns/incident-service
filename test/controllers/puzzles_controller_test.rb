require 'test_helper'

class PuzzlesControllerTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  setup do
    @puzzle = puzzles(:one)
    @user = users(:rishi)
    # https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
    @user.save
    login_as(@user, :scope => :user)
  end

  test "should show puzzle" do
    get puzzle_url(@puzzle)
    assert_response :success
  end

  test "can finish puzzle" do
    get '/puzzles/1/finished'
    assert_redirected_to '/'
  end
end
