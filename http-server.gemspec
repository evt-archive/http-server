Gem::Specification.new do |s|
  s.name        = 'http-server'
  s.version     = '0.0.2.2'
  s.summary     = 'Simple HTTP Server using http-protocol'
  s.description = ' '

  s.authors = ['Obsidian Software, Inc']
  s.email = 'opensource@obsidianexchange.com'
  s.homepage = 'https://github.com/obsidian-btc/http-server'
  s.licenses = ['MIT']

  s.require_paths = ['lib']
  s.files = Dir.glob('{lib}/**/*')
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.2.3'

  s.add_runtime_dependency 'connection'
  s.add_runtime_dependency 'http-commands'
  s.add_runtime_dependency 'http-protocol'
  s.add_runtime_dependency 'settings'

  s.add_development_dependency 'test_bench'
end
