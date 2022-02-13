require_relative "./lib/lab42/rgxargs/version"
Gem::Specification.new do |s|
  s.name        = 'lab42_rgxargs'
  s.version     = Lab42::Rgxargs::VERSION
  s.date        = '2020-01-27'
  s.summary     = 'Parse CL args according to regexen'
  s.description = 'Parse CL args according to regexen'
  s.authors     = ['Robert Dober']
  s.email       = 'robert.dober@gmail.com'
  s.files       = Dir.glob('lib/lab42/**/*.rb')
  s.homepage    =
    'https://github.com/robertdober/lab42_rgxargs'
  s.license       = 'Apache-2.0'

  s.required_ruby_version = '>= 3.1.0'


  s.add_development_dependency 'speculate_about', '~> 0.1.2'
  s.add_development_dependency 'rspec', '~> 3.9'
  s.add_development_dependency 'pry-byebug', '~> 3.7'
  s.add_development_dependency 'pry-doc', '~> 1.0'


end
