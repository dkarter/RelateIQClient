lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'bundler/version'

Gem::Specification.new do |s|
  s.name         = 'relate_iq_client'
  s.version      = '1.0.0'
  s.date         = '2014-10-10'
  s.summary      = 'Wrapper client for RelateIQ'
  s.description  = 'Wrapper client for RelateIQ allows using RelateIQ API from ruby'
  s.authors      = ['Dorian Karter']
  s.email        = 'jobs@doriankarter.com'
  s.files        = `git ls-files`.split("\n").reject { |path| path =~ /\.gitignore$/ }
  s.test_files   = `git ls-files -- {spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/dkarter/relate_iq_client'

  s.add_development_dependency 'bundler', '~> 1.7'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~>3.1'
  s.add_development_dependency 'pry', '~> 0.10'
  s.add_development_dependency 'pry-stack_explorer', '~> 0.4.9'
end
