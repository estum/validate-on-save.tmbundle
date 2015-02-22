module VOS
  module Validate
    def self.coffee
      binary = ENV['TM_COFFEELINT'] ||= "coffeelint"
      options = (ENV['TM_COFFEELINT_OPTS'] || "--color=never").split(/\s+/)

      IO.popen [binary, *options, ENV['TM_FILEPATH'], :err => [:child, :out]], "r" do |io|
        result = io.read.gsub(/^(.+) #(\d+): /, 'Line \2: ')

        VOS.output({
          :info       => "Running syntax check with CoffeeScript lint\n",
          :result     => result,
          :match_ok   => /\b0 errors\b.*\b0 warnings\b/i, # ignore warnings
          :match_line => /line (\d+): /i,
          :lang       => "CoffeeScript"
        })
      end
    end
  end
end
