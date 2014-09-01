module AgileCheckIn
  module Git
    def self.current_branch
      `git branch --no-color 2> /dev/null`.split("\n")
                                          .select{ |branch| branch.match(/\* /) }
                                          .first
                                          .split("* ")
                                          .last
    end
    
    def self.local_commits
      `git log origin/#{current_branch}..HEAD`
    end
    
    def self.has_local_changes?
      !`git status`.match(/working directory clean/)
    end

    def self.push!
      system("git push")
    end

    def self.add_all!
      system("git add -A")
    end

    def self.commit!(editor, author, commit_message)
      system("EDITOR=#{editor} git commit --author='#{author}' -e -m '#{commit_message}'")
    end

    def self.branch_out!(branch_name)
      system("git checkout -b #{branch_name}")
    end
  end
end
