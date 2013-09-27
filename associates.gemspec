# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'associates/version'

Gem::Specification.new do |s|
  s.name          = "associates"
  s.version       = Associates::VERSION
  s.authors       = ["Philippe Dionne"]
  s.email         = ["dionne.phil@gmail.com"]
  s.homepage      = "https://github.com/phildionne/associates"
  s.licenses      = ['MIT']
  s.summary       = "TODO: summary"
  s.description   = "TODO: description"

  s.cert_chain  = ['certs/pdionne-gem-public_cert.pem']
  s.signing_key = File.expand_path("~/.gem/pdionne-gem-private_key.pem") if $0 =~ /gem\z/

  s.files         = `git ls-files lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.test_files    = s.files.grep(%r{^(spec)/})

  s.add_dependency 'activerecord', '>= 3.2.14'
  s.add_dependency 'activesupport', '>= 3.2.14'
end
