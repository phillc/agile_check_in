module AgileCheckIn
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
end
