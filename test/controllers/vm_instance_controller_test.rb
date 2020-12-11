require 'test_helper'

class VmInstanceControllerTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  setup do
    @instance = vm_instances(:one)
    @puzzle = puzzles(:one)
    WebMock.disable_net_connect!
    @user = users(:rishi)
    @user.save
    login_as(@user, :scope => :user)

    stub_request(:get, "https://api.digitalocean.com/v2/account/keys?page=1&per_page=20").
      to_return(status: 200, body: '{"ssh_keys":[],"links":{},"meta":{"total":2}}')

    do_instance = '{"droplet":{"id":220816290,"name":"mystring-40m4y72ptw","memory":1024,"vcpus":1,"disk":25,"locked":false,"status":"new","kernel":null,"created_at":"2020-12-10T15:55:15Z","features":[],"backup_ids":[],"next_backup_window":null,"snapshot_ids":[],"image":{"id":72067660,"name":"20.04 (LTS) x64","distribution":"Ubuntu","slug":"ubuntu-20-04-x64","public":true,"regions":["nyc3","nyc1","sfo1","nyc2","ams2","sgp1","lon1","ams3","fra1","tor1","sfo2","blr1","sfo3"],"created_at":"2020-10-20T16:34:30Z","min_disk_size":15,"type":"base","size_gigabytes":0.52,"description":"Ubuntu 20.04 x86","tags":[],"status":"available"},"volume_ids":[],"size":{"slug":"s-1vcpu-1gb","memory":1024,"vcpus":1,"disk":25,"transfer":1.0,"price_monthly":5.0,"price_hourly":0.00744,"regions":["ams2","ams3","blr1","fra1","lon1","nyc1","nyc2","nyc3","sfo1","sfo2","sfo3","sgp1","tor1"],"available":true},"size_slug":"s-1vcpu-1gb","networks":{"v4":[],"v6":[]},"region":{"name":"New York 3","slug":"nyc3","features":["backups","ipv6","metadata","install_agent","storage","image_transfer"],"available":true,"sizes":["s-1vcpu-1gb","s-1vcpu-2gb","s-2vcpu-2gb","s-2vcpu-4gb","s-4vcpu-8gb","m-1vcpu-8gb","c-2","c2-2vcpu-4gb","g-2vcpu-8gb","gd-2vcpu-8gb","s-8vcpu-16gb","m-2vcpu-16gb","c-4","c2-4vpcu-8gb","m3-2vcpu-16gb","g-4vcpu-16gb","m6-2vcpu-16gb","gd-4vcpu-16gb","m-4vcpu-32gb","c-8","c2-8vpcu-16gb","m3-4vcpu-32gb","g-8vcpu-32gb","m6-4vcpu-32gb","gd-8vcpu-32gb","m-8vcpu-64gb","c2-16vcpu-32gb","m3-8vcpu-64gb","g-16vcpu-64gb","m6-8vcpu-64gb","gd-16vcpu-64gb","m-16vcpu-128gb","c2-32vpcu-64gb","m3-16vcpu-128gb","m-24vcpu-192gb","g-32vcpu-128gb","m6-16vcpu-128gb","m3-24vcpu-192gb","m6-24vcpu-192gb","m3-32vcpu-256gb","m6-32vcpu-256gb"]},"tags":[]},"links":{"actions":[{"id":1087950206,"rel":"create","href":"https://api.digitalocean.com/v2/actions/1087950206"}]}}'
    stub_request(:post, "https://api.digitalocean.com/v2/droplets").
      to_return(status: 202, body: do_instance, headers: {})

  end

  test "starting puzzle should create a vm instance" do
    assert_difference('VmInstance.count') do
      get '/puzzles/1/start'
    end
    assert_redirected_to '/puzzles/1/play'
  end

  test "can't show a puzzle before starting it" do
    get '/puzzles/1/play'
    assert_redirected_to puzzle_url(@puzzle)
  end

  test "status is pending right after instance started" do
    get '/puzzles/1/start'
    get '/instances/220816290/status'
    assert_response :success
    assert_equal({"status" => "pending"}, response.parsed_body)
  end



  test "can show a puzzle after starting it" do
    get '/puzzles/1/start'
    instance = VmInstance.find_by(status: :pending)
    instance.running! # force instance to running, TODO: add an actual mechanism for this to happen
    get '/puzzles/1/play'
    assert_response :success
  end
end