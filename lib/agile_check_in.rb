require "agile_check_in/version"
require "yaml"

module AgileCheckIn
  def self.incremental
    pair_names = ""
    story_number = ""

    history_file = '.shove_history.yml'
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
      $stdout.write "Story number [#{story_number}]: "
      input = $stdin.gets.strip
      story_number = input unless input.empty?
    end until !story_number.empty?

    File.open(history_file, 'w') do |out|
      YAML.dump({ "shove" => { "pair" => pair_names, "story" => story_number } }, out)
    end

    commit_message = "[#{pair_names} - ##{story_number}] "

    system("git add -A")
    system("EDITOR=vim git commit -e -m '#{commit_message}'")
  end

  def self.push_and_test
    puts "*******"
    puts "About to test these changes:"
    puts `git log origin/develop..HEAD`
    puts "*******"


    if system("rake spec")
      puts "*******"
      puts "About to push these changes:"
      puts `git log origin/develop..HEAD`
      puts "*******"
      puts "Shoving..."
      system("git push origin develop")
    else
      puts "Tests failed. Shove aborted."
      exit(1)
    end
  end
end
