require "agile_check_in/version"
require "agile_check_in/git"
require "yaml"

module AgileCheckIn
  def self.incremental options={}
    pair_names = ""
    story_number = ""

    if Git.has_local_changes?
      history_file = '/tmp/agile_check_in_history.yml'
      if File.exists?(history_file)
        shove_history = YAML::load(File.open(history_file))["shove"]
        pair_names    = shove_history["pair"]
        story_number  = shove_history["story"]
      end

      begin
        $stdout.write "Pair names (separated with '/') [#{pair_names}]: "
        input = $stdin.gets.strip
        pair_names = input unless input.empty?
      end until !pair_names.empty?

      begin
        $stdout.write "Story number (NA) [#{story_number}]: "
        input = $stdin.gets.strip
        story_number = input unless input.empty?
      end until !story_number.empty?

      File.open(history_file, 'w') do |out|
        YAML.dump({ "shove" => { "pair" => pair_names, "story" => story_number } }, out)
      end

      if story_number.delete("/").downcase == "na"
        commit_message = ""
      else
        commit_message = "[##{story_number}] "
      end

      author = "#{pair_names} <agile_check_in@#{`hostname`}>"

      system("git add -A") if options[:add]
      system("EDITOR=vim git commit --author='#{author}' -e -m '#{commit_message}'")
    else
      puts "No local changes to commit."
    end

  end

  def pre_commit_tasks
   if File::exists? '.agile_check_in.yml'
      config_hash = YAML::load(File.read('.agile_check_in.yml'))
      pre_commit_tasks = config_hash["pre_commit"]
   end
  end

  def self.push_and_test
    puts "*******"
    puts "About to test these changes:"
    puts Git.local_commits
    puts "*******"

    if pre_commit_tasks
      if system(pre_commit_tasks)
        puts "*******"
        puts "About to push these changes:"
        puts Git.local_commits
        puts "*******"
        puts "Shoving..."
        system("git push")
      else
        puts "Tests failed. Shove aborted."
        exit(1)
      end
    end

  end
end
