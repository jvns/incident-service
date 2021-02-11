class Puzzle < ActiveHash::Base
  def to_param
    "#{id}-#{slug}"
  end

  def finished?(user)
    PuzzleStatus.where(user_id: user.id).where(puzzle_id: self.id).first&.finished || false
  end

  def cloud_init
    File.read(cloud_init_filename)
  end

  def self.published_puzzles
    Puzzle.all.filter{|x| x.published?}
  end

  def puzzle_text
    yaml = YAML.load_file(cloud_init_filename)
    puzzle_item = yaml['write_files'].find{|x| x['path'].include?('puzzle.txt')}
    puzzle_item['content']
  end

  self.data = [
    {
      id: 1,
      group: "networking",
      slug: "connection-timeout",
      title: "The Case of the Connection Timeout",
      published: false,
      description: "",
    },
    {
      id: 2,
      group: "fun-with-files",
      slug: "write-write-write",
      title: "The Case of the Rapidly Filling Hard Drive",
      published: false,
      description: "",
    },
    {
      id: 3,
      slug: "cant-make-files",
      group: "fun-with-files",
      published: false,
      title: 'The Case of "I can\'t create a file!"',
      description: "",
    },
    {
      id: 4,
      slug: "deleted-file",
      group: "fun-with-files",
      title: "The Case of the Deleted File",
      published: false,
      description: "",
    },
    {
      id: 5,
      slug: "403-forbidden",
      group: "fun-with-files",
      title: "The Case of the 403 Forbidden",
      description: <<~EOS,
      hi
      EOS
      published: false,
    },
    {
      id: 6,
      slug: "run-me",
      group: "fun-with-files",
      weight: 1,
      description: <<~EOS,
      There will be a file in your home directory called `run-me`. Run it (with
      `./run-me`).

      As always, there's a problem: the program won't run! You get a
      "permission denied" error. Your mission is to find out why and fix it.

      This one is a basic unix permissions puzzle.
      EOS
      title: "The Case of the Program that Won't Run",
      published: false,
    },
    {
      id: 7,
      slug: "read-me",
      group: "fun-with-files",
      title: "The Case of the File You Can't Read",
      description: <<~EOS,
      There's a file in your home directory called `read-me`. Your mission is
      to read it (with `cat read-me`).

      You'll find that there's a problem: a permission denied error! But this
      one isn't as simple to fix as the previous puzzle. There are hints if you
      get stuck.
      EOS
      published: false,
    },
    {
      id: 8,
      slug: "write-secret-string",
      group: "strace",
      password: 'squid',
      title: "The Case of the Misconfigured Logger",
      description: <<~EOS,
      There's a program in your home directory called `write-secret-string`.  For
      some reason, it's been misconfigured so that it's writing its
      logs to /dev/null instead of to a file. But you need to know
      what it's writing!

      Use strace to find out what it's writing. The answer is a sea animal.
      EOS
      solution: <<~EOS,
      The 
      EOS
      published: true,
    },
    {
      id: 9,
      slug: "mystery-log-file",
      group: "strace",
      password: 'crayfish',
      title: "The Case of the Mystery Log File",
      description: <<~EOS,
      There's a program in the puzzle directory called `run-me`. It's
      logging its output to a log file, but you can't find the name
      of the log file ANYWHERE in its documentation!

      The password is in the name of the log file (it's a crustacean). Use strace to figure it out.
      EOS
      solution: <<~EOS,
      The fastest way to solve this puzzle is

      ```
      strace -e openat ./run-me
      ```

      You can also run

      ```
      strace -e file ./run-me
      ```

      to trace a bunch of different system calls related to files (including `openat`).

      EOS
      published: true,
    }
  ]
  private
  
  def cloud_init_filename
    "puzzles/#{group}/#{slug}/cloud-init.yaml"
  end
end

