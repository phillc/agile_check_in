require "agile_check_in/version"
require "agile_check_in/git"
require "yaml"

module AgileCheckIn
  module Shove
    HISTORY_FILE = '/tmp/agile_check_in_history.yml'

    def self.load
      if File.exists?(HISTORY_FILE)
        shove_history = YAML::load(File.open(HISTORY_FILE))["shove"]
        return [shove_history["pair"], shove_history["story"]]
      end
      []
    end

    def self.dump!(pair_names, story_number)
      File.open(HISTORY_FILE, 'w') do |out|
        YAML.dump({ "shove" => { "pair" => pair_names, "story" => story_number } }, out)
      end
    end
  end

  module UI
    def self.details(default)
      ask_with_default('Story description', default)
    end

    def self.pair_names(default)
      ask_with_default('Pair names (separated with \'/\')', default)
    end

    def self.story_number(default)
      ask_with_default('Story number (NA)', default)
    end

    def self.ask_with_default(question, current)
      begin
        $stdout.write "#{question} [#{current}]: "
        input = $stdin.gets.strip
        current = input unless input.empty?
      end until !current.empty?
      current
    end
  end

  module Formatting
    DEFAULT_EDITOR='vim'

    def self.format_story_prefix(story_number)
      return "" if story_number.delete("/").downcase == "na"
      "[##{story_number}] "
    end

    def self.format_author(pair_names)
      "#{pair_names} <agile_check_in@#{`hostname`}>"
    end

    def self.format_branch_name(pair_names, story_number, description)
      sanitized_pair_names = pair_names.gsub(/[^a-zA-Z0-9]/, '_')
      sanitized_description = description.gsub(/[^a-zA-Z0-9]/, '_')

      "#{sanitized_pair_names}/#{sanitized_description}"
    end
  end

  def self.branch_out
    pair_names, story_number = *story_details
    description = UI.details('bug fix')

    Git.branch_out! Formatting.format_branch_name(pair_names, story_number, description)
  end

  def self.incremental(options={})
    if Git.has_local_changes?
      pair_names, story_number = story_details

      Git.add_all! if options[:add]
      Git.commit! Formatting::DEFAULT_EDITOR, Formatting.format_author(pair_names), Formatting.format_story_prefix(story_number)
    else
      puts 'No local changes to commit.'
    end
  end

  def self.story_details
    pair_names, story_number = *Shove.load

    pair_names = UI.pair_names(pair_names)
    story_number = UI.story_number(story_number)

    Shove.dump! pair_names, story_number

    [pair_names || '', story_number || '']
  end

  def self.pre_commit_tasks
    if File::exists? '.agile_check_in.yml'
      file = File.read('.agile_check_in.yml')
      pre_commit_tasks = YAML::load(file)["pre_commit"]
    end
  end

  def self.push_commits
    puts '*******'
    puts 'About to push these changes:'
    puts Git.local_commits
    puts '*******'
    puts 'Shoving...'
    Git.push!
  end

  def self.push_and_test
    if pre_commit_tasks
      if system(pre_commit_tasks)
        push_commits
      else
        puts 'Tests failed. Shove aborted.'
        exit(1)
      end
    else
      push_commits
    end
  end
end
