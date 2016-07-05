$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'micro_client/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'micro_client'
  s.version     = MicroClient::VERSION
  s.authors     = ['zuozuo']
  s.email       = ['zzhattzzh@126.com']
  s.homepage    = 'TODO'
  s.summary     = 'TODO: Summary of MicroClient.'
  s.description = 'TODO: Description of MicroClient.'
  s.license     = 'MIT'

  s.files = Dir[
    '{app,config,db,lib}/**/*',
    'MIT-LICENSE',
    'Rakefile',
    'README.md'
  ]

  s.add_dependency 'oj'
  s.add_dependency 'http'
  s.add_dependency 'diplomat'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'single_test'
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
	s.add_development_dependency 'activesupport'
end
