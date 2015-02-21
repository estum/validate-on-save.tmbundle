module VOS
  module Validate
    def self.ruby
      ruby_bin = ENV['TM_RUBY'] || "ruby"
      ruby_version = `#{ruby_bin} -v`
      IO.popen([ruby_bin, "-wc", ENV['TM_FILEPATH'], :err => [:child, :out]], "r") do |io|
        result = io.gets.gsub(/^(.+?)\:([0-9]+)\: /i, 'Line \2: ')
        VOS.output({
          :info => "Running syntax check with #{ruby_version}\n",
          :result => result,
          :match_ok => /(?<!\n)Syntax OK/im,
          :match_line => /line (\d+)/i,
          :lang => "Ruby"
        })
      end
    end
  end
end