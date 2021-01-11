client = DropletKit::Client.new(access_token: ENV['DO_TOKEN'])
client.droplets.all.each do |droplet|
  minutes_ago = ((Time.now - Time.parse(droplet.created_at)) / 60).to_i
  # we run this every 2 minutes so we need to make sure to kill it before it
  # gets to being an hour old 
  if droplet.tags.include?('debugging-school') and minutes_ago >= 56
    puts "Deleting droplet id=#{droplet.id} name=#{droplet.name} age=#{minutes_ago}"
    # TODO: maybe put in some error handling here
    client.droplets.delete(id: droplet.id) 
  end
end
