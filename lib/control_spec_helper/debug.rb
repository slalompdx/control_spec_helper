module ControlSpecHelper
  module Debug
    def self.log(msg)
      $stderr.puts "DEBUG: #{msg}" unless ENV['debug'].nil?
    end
  end
end
