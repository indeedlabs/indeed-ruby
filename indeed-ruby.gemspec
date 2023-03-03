Gem::Specification.new do |s|
  s.name = 'indeed-ruby'
  s.version = '0.0.2'
  s.author = 'Indeed Labs'
  s.email = 'labs-team@indeed.com'

  s.description = 'Indeed Job Search Ruby Api Client'
  s.summary = 'Indeed Job Search Ruby Api Client'
  s.homepage = 'http://github.com/indeedlabs/indeed-ruby'

  s.files = ["lib/indeed-ruby.rb"]

  s.add_dependency('rest-client', '>= 1.6.7')
  s.add_dependency('json', '>= 1.7.5')
end