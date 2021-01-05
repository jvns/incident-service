class Puzzle < ActiveHash::Base
  def to_param
    "#{id}-#{slug}"
  end

  def finished?(user)
    PuzzleStatus.where(user_id: user.id).where(puzzle_id: self.id).first&.finished || false
  end

  def cloud_init
    File.open("puzzles/#{group}/#{slug}/cloud-init.yaml")
  end

  self.data = [
    {
      id: 1,
      group: "networking",
      slug: "connection-timeout",
      title: "The Case of the Connection Timeout",
      published: false,
    },
    {
      id: 2,
      group: "fun-with-files",
      slug: "write-write-write",
      title: "The Case of the Rapidly Filling Hard Drive",
      published: false,
    },
    {
      id: 3,
      slug: "cant-make-files",
      group: "fun-with-files",
      published: false,
      title: 'The Case of "I can\'t create a file!"',
    },
    {
      id: 4,
      slug: "deleted-file",
      group: "fun-with-files",
      title: "The Case of the Deleted File",
      published: false,
    },
    {
      id: 5,
      slug: "403-forbidden",
      group: "fun-with-files",
      title: "The Case of the 403 Forbidden",
      published: false,
    },
    {
      id: 6,
      slug: "run-me",
      group: "fun-with-files",
      title: "The Case of the Program that Won't Run",
      published: false,
    }
  ]
end

