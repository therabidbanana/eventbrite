Gem::Specification.new do |s|
  s.name = "eventbrite"
  s.version = "0.4.2"
  s.authors = ["David Haslem"]
  s.date = "2012-04-15"
  s.description = "A simple, unoffical gem that integrates with the EventBrite events service. (http://www.eventbrite.com)"
  s.email = "therabidbanana@gmail.com"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.homepage = "http://github.com/therabidbanana/eventbrite"
  s.require_paths = ["lib"]
  s.summary = "An unofficial gem for EventBrite Integration"

  s.add_development_dependency(%q<rspec>, "~> 2.0")
  s.add_dependency(%q<httparty>, "~> 0.8.0")
  s.add_dependency(%q<tzinfo>, "~> 0.3.22")
end

