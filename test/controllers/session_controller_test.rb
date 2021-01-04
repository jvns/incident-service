require 'test_helper'
require 'net/ssh/test'

class SessionControllerTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  include Net::SSH::Test
  setup do
    @instance = sessions(:one)
    @puzzle = puzzles(:one)
    WebMock.disable_net_connect!
    @user = users(:rishi)
    @user.save
    login_as(@user, :scope => :user)

    stub_request(:get, "https://api.digitalocean.com/v2/account/keys?page=1&per_page=20").
      to_return(status: 200, body: '{"ssh_keys":[],"links":{},"meta":{"total":2}}')

    do_instance = '{"droplet":{"id":220816290,"name":"mystring-40m4y72ptw","memory":1024,"vcpus":1,"disk":25,"locked":false,"status":"new","kernel":null,"created_at":"2020-12-10T15:55:15Z","features":[],"backup_ids":[],"next_backup_window":null,"snapshot_ids":[],"image":{"id":72067660,"name":"20.04 (LTS) x64","distribution":"Ubuntu","slug":"ubuntu-20-04-x64","public":true,"regions":["nyc3","nyc1","sfo1","nyc2","ams2","sgp1","lon1","ams3","fra1","tor1","sfo2","blr1","sfo3"],"created_at":"2020-10-20T16:34:30Z","min_disk_size":15,"type":"base","size_gigabytes":0.52,"description":"Ubuntu 20.04 x86","tags":[],"status":"available"},"volume_ids":[],"size":{"slug":"s-1vcpu-1gb","memory":1024,"vcpus":1,"disk":25,"transfer":1.0,"price_monthly":5.0,"price_hourly":0.00744,"regions":["ams2","ams3","blr1","fra1","lon1","nyc1","nyc2","nyc3","sfo1","sfo2","sfo3","sgp1","tor1"],"available":true},"size_slug":"s-1vcpu-1gb","networks":{"v4":[],"v6":[]},"region":{"name":"New York 3","slug":"nyc3","features":["backups","ipv6","metadata","install_agent","storage","image_transfer"],"available":true,"sizes":["s-1vcpu-1gb","s-1vcpu-2gb","s-2vcpu-2gb","s-2vcpu-4gb","s-4vcpu-8gb","m-1vcpu-8gb","c-2","c2-2vcpu-4gb","g-2vcpu-8gb","gd-2vcpu-8gb","s-8vcpu-16gb","m-2vcpu-16gb","c-4","c2-4vpcu-8gb","m3-2vcpu-16gb","g-4vcpu-16gb","m6-2vcpu-16gb","gd-4vcpu-16gb","m-4vcpu-32gb","c-8","c2-8vpcu-16gb","m3-4vcpu-32gb","g-8vcpu-32gb","m6-4vcpu-32gb","gd-8vcpu-32gb","m-8vcpu-64gb","c2-16vcpu-32gb","m3-8vcpu-64gb","g-16vcpu-64gb","m6-8vcpu-64gb","gd-16vcpu-64gb","m-16vcpu-128gb","c2-32vpcu-64gb","m3-16vcpu-128gb","m-24vcpu-192gb","g-32vcpu-128gb","m6-16vcpu-128gb","m3-24vcpu-192gb","m6-24vcpu-192gb","m3-32vcpu-256gb","m6-32vcpu-256gb"]},"tags":[]},"links":{"actions":[{"id":1087950206,"rel":"create","href":"https://api.digitalocean.com/v2/actions/1087950206"}]}}'
    do_instance_started = '{"droplet":{"id":220816290,"name":"mystring-40m4y72ptw","memory":1024,"vcpus":1,"disk":25,"locked":false,"status":"new","kernel":null,"created_at":"2020-12-10T15:55:15Z","features":[],"backup_ids":[],"next_backup_window":null,"snapshot_ids":[],"image":{"id":72067660,"name":"20.04 (LTS) x64","distribution":"Ubuntu","slug":"ubuntu-20-04-x64","public":true,"regions":["nyc3","nyc1","sfo1","nyc2","ams2","sgp1","lon1","ams3","fra1","tor1","sfo2","blr1","sfo3"],"created_at":"2020-10-20T16:34:30Z","min_disk_size":15,"type":"base","size_gigabytes":0.52,"description":"Ubuntu 20.04 x86","tags":[],"status":"available"},"volume_ids":[],"size":{"slug":"s-1vcpu-1gb","memory":1024,"vcpus":1,"disk":25,"transfer":1.0,"price_monthly":5.0,"price_hourly":0.00744,"regions":["ams2","ams3","blr1","fra1","lon1","nyc1","nyc2","nyc3","sfo1","sfo2","sfo3","sgp1","tor1"],"available":true},"size_slug":"s-1vcpu-1gb","networks":{"v4":[{"ip_address":"10.108.0.3","netmask":"255.255.240.0","gateway":"","type":"private"},{"ip_address":"104.131.171.68","netmask":"255.255.240.0","gateway":"104.131.160.1","type":"public"}],"v6":[]},"region":{"name":"New York 3","slug":"nyc3","features":["backups","ipv6","metadata","install_agent","storage","image_transfer"],"available":true,"sizes":["s-1vcpu-1gb","s-1vcpu-2gb","s-2vcpu-2gb","s-2vcpu-4gb","s-4vcpu-8gb","m-1vcpu-8gb","c-2","c2-2vcpu-4gb","g-2vcpu-8gb","gd-2vcpu-8gb","s-8vcpu-16gb","m-2vcpu-16gb","c-4","c2-4vpcu-8gb","m3-2vcpu-16gb","g-4vcpu-16gb","m6-2vcpu-16gb","gd-4vcpu-16gb","m-4vcpu-32gb","c-8","c2-8vpcu-16gb","m3-4vcpu-32gb","g-8vcpu-32gb","m6-4vcpu-32gb","gd-8vcpu-32gb","m-8vcpu-64gb","c2-16vcpu-32gb","m3-8vcpu-64gb","g-16vcpu-64gb","m6-8vcpu-64gb","gd-16vcpu-64gb","m-16vcpu-128gb","c2-32vpcu-64gb","m3-16vcpu-128gb","m-24vcpu-192gb","g-32vcpu-128gb","m6-16vcpu-128gb","m3-24vcpu-192gb","m6-24vcpu-192gb","m3-32vcpu-256gb","m6-32vcpu-256gb"]},"tags":[]},"links":{"actions":[{"id":1087950206,"rel":"create","href":"https://api.digitalocean.com/v2/actions/1087950206"}]}}'
    stub_request(:post, "https://api.digitalocean.com/v2/droplets").
      to_return(status: 202, body: do_instance, headers: {})

    stub_request(:get, "https://api.digitalocean.com/v2/droplets/220816290").
      to_return(status: 200, body: do_instance_started)



  end

  test "starting puzzle should create a vm instance" do
    assert_difference('Session.count') do
      post sessions_url, params: { puzzle_id: 1 }
    end
    assert_redirected_to session_url(Session.last) 
  end

  def mock_successful_ssh_connection
    ssh_conn = Minitest::Mock.new
    ssh_conn.expect(:exec!, "some command output", args=['ls'])
    ssh_conn.expect(:exec!, "some command output", args=['sudo bash files/run.sh'])
    ssh_conn.expect(:exec!, "some command output", args=['sudo rm files/run.sh'])
    Net::SSH.stub :start, ssh_conn do
      yield
    end
  end

  def mock_timeout_ssh_connection
    ssh_conn = Minitest::Mock.new
    raises_exception = ->(a,b,c) { raise Net::SSH::ConnectionTimeout }
    Net::SSH.stub :start, raises_exception do
      yield
    end
  end

  test "status is pending right after instance started" do
    post sessions_url, params: { puzzle_id: 1 }
    mock_timeout_ssh_connection do
      get session_url(Session.last), headers: {"Accept": "application/json"}
    end
    assert_response :success
    assert_equal({"status" => "pending"}, response.parsed_body)
  end

  test "status is successful after a successful ssh connection" do
    post sessions_url, params: { puzzle_id: 1 }
    mock_successful_ssh_connection do
      get session_url(Session.last), headers: {"Accept": "application/json"}
    end
    assert_response :success
    assert_equal({"status" => "running"}, response.parsed_body)
  end

  test "instance list is empty right after puzzle starts" do
    post sessions_url, params: { puzzle_id: 1 }
    get sessions_url
    assert_response :success
    assert_equal({}, response.parsed_body)
  end

  test "listing instances works" do
    post sessions_url, params: { puzzle_id: 1 }
    mock_successful_ssh_connection do
      get session_url(Session.last), headers: {"Accept": "application/json"}
    end
    get sessions_url
    assert_equal(1, response.parsed_body.size)
  end

  test "admin page works" do
    @user = users(:julia)
    @user.save
    login_as(@user, :scope => :user)
    get '/admin'
    assert_response :success
  end

  test "admin page redirects for normal users" do
    get '/admin'
    assert_redirected_to '/'
  end
end
