eventbrite
================

This gem is no longer actively maintained, though I do try to fix any reported
bugs. For a more official gem, see: https://github.com/ryanjarvinen/eventbrite-client.rb

A simple library for integrating with EventBrite's API. Requires the "httparty" gem 
for connecting and doing XML parsing, and "tzinfo" gem for getting back and forth 
between timezone names and GMT offsets.

The gem was recently renamed from Eventbright - since that was
a confusing name. 

Usage
-----

    require 'eventbrite'
    Eventbrite.setup("APP_KEY")
    user = Eventbrite::User.new("USER_KEY") #=> <Eventbrite::User >
    user.venues #=> [<Eventbrite::Venue>,...] # Venues the user has defined


Some basic (yardoc generated) documentation availabe at: http://rdoc.info/github/therabidbanana/eventbrite/

This library attempts to create an almost ActiveResource like wrapper
around the Eventbrite api. The following objects are available:

* Attendee (can only be viewed, not edited)
* Discount
* Event (has many Tickets, Attendees, Discounts, has one Venue and
  one Organizer)
* Organizer (has many Events)
* Ticket
* User (has many Events, Organizers, Venues)
* Venue



Authentication
--------------
Many methods require user authentication. For these methods, you can pass a user object as an authentication token, and the user's api_key will automatically be used for the request. 

Example:
    
    Eventbrite::Event.new({"x" => "y"... , "user" => user})

Known Issues
----------

1. This library's testing coverage is almost zero. 
2. There is no subuser support.


A Note About App Keys
---------------------

This gem has an application key for accessing EventBrite, but each app key is limited to 30,000 requests a day. To make sure your limits aren't affected by others, you should register for your own app key specific to the application you're adding the gem to. 

If you just want to give the gem a whirl (you have to wait for approval to get your own) just don't call setup. The app key for the gem will be used.

Learn more about EventBrite's App Key policy here: [Terms of Service](http://www.eventbrite.com/api/terms)

Register for your own app key here: [Request a Key](http://www.eventbrite.com/api/key/)


API Gotchas 
------------

There are some sticky points to the Eventbrite api this library helps with - read the details at: http://therabidbanana.github.com/eventbrite/file.ImplementationGotchas.html


Note on Patches/Pull Requests
-----------------------------
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2010 David Haslem. See LICENSE for details.
