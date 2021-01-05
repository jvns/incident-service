slug = ARGV[0]
puzzle = Puzzle.find_by(slug: slug)
puts "Starting puzzle #{puzzle.title}"
user = User.find(1)
session = Session.find_or_create_by(user_id: user.id, puzzle_id: puzzle.id)
droplet = session.droplet
require 'pry'
binding.pry
