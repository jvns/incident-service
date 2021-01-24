require 'net/http'

class Ignite
  def initialize(session)
    @session = session
  end
  attr_accessor :session

  def status
    return nil unless session
    if session.waiting_for_ssh?
      if ip_address
        session.running!
      end
    end
    session.status
  end

  def launch!
    resp = request("http://host:9090/create", {image: "jvns/game:base"})
    resp['id']
  end

  def destroy!
    begin
      request("http://host:9090/delete", {id: @session.vm_id})
    rescue
    end
  end

  def ip_address
    @session.ip_address ||= find_ip_address
  end

  def request(url, body)
    uri = URI(url)
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = body.to_json
    resp = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    JSON.parse(resp.body)
  end

  def find_ip_address
    resp = request("http://host:9090/ip_address", {id: @session.vm_id})
    begin 
      resp['ip_address']
    rescue
      nil
    end
  end
end
