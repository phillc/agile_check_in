require "agile_check_in/version"
require "agile_check_in/shove"
require "agile_check_in/ui"
require "agile_check_in/formatting"
require "agile_check_in/git"
require "yaml"

module AgileCheckIn
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
