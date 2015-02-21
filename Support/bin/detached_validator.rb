#!/usr/bin/env ruby

require ENV['TM_BUNDLE_SUPPORT'] + "/lib/validate_on_save"

if ARGV.any?
  VOS::Validate.call(ARGV.first)
else
  VOS::Validate.validate
end