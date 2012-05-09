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
  end
end