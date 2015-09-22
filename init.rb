unless ENV["DISABLE_BUNDLER"]
  require "bundler"
  Bundler.setup
end

lib_dir = File.expand_path "../lib", __FILE__
unless $LOAD_PATH.include? lib_dir
  $LOAD_PATH << lib_dir
end

require "http/server"
