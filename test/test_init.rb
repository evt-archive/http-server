ENV['CONSOLE_DEVICE'] ||= 'stdout'
ENV['LOG_COLOR'] ||= 'on'
ENV['LOG_LEVEL'] ||= 'trace'

puts RUBY_DESCRIPTION

require_relative '../init.rb'

require 'process_host'
require 'runner'

require 'http/server/controls'

Telemetry::Logger::AdHoc.activate
