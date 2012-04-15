require 'rubygems'
require 'rake'


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
