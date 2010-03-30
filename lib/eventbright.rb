libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require File.join(libdir, 'eventbright', 'main.rb')
Dir.glob(File.join(libdir, 'eventbright', '*.rb')).each {|f| require f }
