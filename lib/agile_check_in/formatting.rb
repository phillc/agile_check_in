module AgileCheckIn
  module Formatting
    DEFAULT_EDITOR='vim'

    def self.format_story_prefix(story_number)
      return "" if story_number.empty?
      "[##{story_number}] "
    end

    def self.format_author(pair_names)
      "#{pair_names} <agile_check_in@#{`hostname`}>"
    end

    def self.format_branch_name(pair_names, story_number, description)
      sanitized_pair_names = pair_names.gsub(/[^a-zA-Z0-9]/, '_')
      sanitized_description = description.gsub(/[^a-zA-Z0-9]/, '_')
      sanitized_story_number = story_number.empty?? '' : "#{story_number}_"

      "#{sanitized_pair_names}/#{sanitized_story_number}#{sanitized_description}"
    end
  end
end
