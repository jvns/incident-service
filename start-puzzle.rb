def wait_until_started(droplet)
  start = Time.now
  while droplet.status != "running"
    puts (Time.now - start).round
    sleep 2
  end
end

 
slug = ARGV[0]
puzzle = Puzzle.find_by(slug: slug)
puts "Starting puzzle #{puzzle.title}"
user = User.find(1)
session = Session.find_or_create_by(user_id: user.id, puzzle_id: puzzle.id)
droplet = session.droplet
wait_until_started(droplet)
puts "ssh -i wizard.key wizard@#{droplet.ip_address}"
