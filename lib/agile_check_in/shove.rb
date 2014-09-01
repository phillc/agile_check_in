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
end
