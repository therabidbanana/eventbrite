libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require File.join(libdir, 'eventbrite', 'main.rb')
Dir.glob(File.join(libdir, 'eventbrite', '*.rb')).each {|f| require f }
require File.join(libdir, 'eventbrite', 'api_objects', 'event.rb')
Dir.glob(File.join(libdir, 'eventbrite', 'api_objects', '*.rb')).each {|f| require f }
