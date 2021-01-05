Session.all.each do |s|
  puts "Destroying session #{s.id} for #{s.puzzle.title}"
  s.destroy!
end
