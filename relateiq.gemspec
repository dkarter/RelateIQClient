# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'relateiq/version'

Gem::Specification.new do |s|
  s.name         = 'relateiq_client'
  s.version      = RelateIq::VERSION 
  s.authors      = ['Dorian Karter']
  s.email        = 'jobs@doriankarter.com'

  s.summary      = 'Wrapper client for RelateIQ API'
  s.description  = 'Wrapper client for RelateIQ allows using RelateIQ API from ruby'
  s.homepage     = 'https://github.com/dkarter/relate_iq_client'
  s.license      = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  s.bindir        = 'bin'
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = [ 'lib' ]

  s.add_dependency 'rest-client', '~> 1.8'

  s.add_development_dependency 'bundler', '~> 1.7'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~>3.1'
  s.add_development_dependency 'pry', '~> 0.10'
  s.add_development_dependency 'pry-stack_explorer', '~> 0.4.9'
  s.add_development_dependency 'zenflow'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-json'
  s.add_development_dependency 'cadre'
  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'webmock'
end
