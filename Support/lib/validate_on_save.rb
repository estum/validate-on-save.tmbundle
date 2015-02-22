require ENV['TM_SUPPORT_PATH'] + "/lib/textmate"
ENV['PATH'] += ":#{ENV['TM_BUNDLE_SUPPORT']}/bin"

$LOAD_PATH << ENV['TM_BUNDLE_SUPPORT'] + "/lib"

require "validate_on_save/constantize"
require "validate_on_save/defaults"
require "validate_on_save/trim"
# require "validate_on_save/validators"

#
# Internal constants
#

GROWL_BIN = ENV["TM_GROWLNOTIFY"] ||= ENV["TM_BUNDLE_SUPPORT"] + "/bin/growlnotify"


#
# Main VOS Class
#

module VOS
  SCOPES = {
    :coffee  => { :is => "source.coffee" },
    :css     => { :is => "source.css" },
    :erb     => { :is => ["text.html.ruby", "text.html source.ruby"] },
    :erlang  => { :is => "source.erlang" },
    :haml    => { :is => "text.haml" },
    :js      => { :is => ["source.js", "source.prototype.js"], :not => ["source.js.embedded.html"] },
    :json    => { :is => "source.json" },
    :php     => { :is => "source.php" },
    :python  => { :is => "source.python" },
    :ruby    => { :is => "source.ruby", :not => ["source.ruby.embedded", "source.ruby.embedded.haml", "text.html.ruby"] },
    :sass    => { :is => "source.sass" },
  }.each_value {|lang| lang.each {|k,src| lang[k] = Regexp.union(src) } }

  module Validate
    def self.call(lang)
      require "validate_on_save/validators/#{lang}"
      send(lang)
    end
  end

  #
  # Main methods
  #

  def self.validate
    scope = ENV["TM_SCOPE"]
    lang = SCOPES.find([]) {|_,match| match[:is] =~ scope && !(match.key?(:not) && (match[:not] =~ scope)) }.first
    Validate.call(lang) if lang
  end

  def self.output(options = {})
    info = options[:info] ||= ""
    info = "" if !opt("VOS_VALIDATOR_INFO")
    result = options[:result] ||= ""
    match_ok = options[:match_ok] ||= ""
    match_line = options[:match_line] ||= ""
    lang = options[:lang] ||= ""
    result_mod = options[:result_mod] ||= ""

    if match_ok =~ result
      if !opt("VOS_ONLY_ON_ERROR")
        notify lang, "Low", info + "Syntax OK"
      end
    else
      yield(result) if block_given?
      notify lang, "Emergency", info + result
      TextMate.go_to :line => $1 if result =~ match_line && opt("VOS_JUMP_TO_ERROR")
    end
  end

  #
  # Util methods
  #

  class << self
    def opt(key)
      if ENV.has_key?(key)
        return (ENV[key] == "true") ? true : false
      else
        return key.constantize
      end
    end

    private
    def notify(lang, priority, message)
      tm_notify(message) if opt("VOS_TM_NOTIFY")
      growl_notify(lang, priority, message) if opt("VOS_GROWL")
    end

    def tm_notify(message)
      puts message
    end

    def growl_notify(lang, priority, message)
      IO.popen "\"#{GROWL_BIN}\" -p '#{priority}' -n 'Textmate Syntax Check' -t '#{lang} Syntax Check' -a 'Textmate'", "w" do |io|
        io.write message
      end
    end

    def bugreport
      require "#{ENV['TM_SUPPORT_PATH']}/lib/browser"
      Browser.load_url('http://github.com/sxtxixtxcxh/validate-on-save.tmbundle/issues')
    end
  end
end
