module SessionHelper
  def gotty_proxy_url
    "/proxy/#{@session.proxy_id}-#{@puzzle.id}/"
  end
end
