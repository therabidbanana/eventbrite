require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "eventbrite"
    gem.summary = %Q{An unofficial gem for EventBrite Integration}
    gem.description = %Q{A simple, unoffical gem that integrates with the EventBrite events service. (http://www.eventbrite.com)}
    gem.email = "therabidbanana@gmail.com"
    gem.homepage = "http://github.com/therabidbanana/eventbrite"
    gem.authors = ["David Haslem"]
    gem.add_development_dependency "rspec", "~> 1.3.0"
    gem.add_dependency "httparty", "~> 0.7.0"
    gem.add_dependency "tzinfo", "~> 0.3.22"

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :irb

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "eventbrite #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


desc "Runs irb with eventbrite lib"
task :irb do
  sh "irb -r 'lib/eventbrite'"
end
