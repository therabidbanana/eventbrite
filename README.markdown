eventbright
-----------

A simple library for integrating with EventBrite's API. Requires the "httparty" gem for connecting and doing XML parsing.

Usage
-----

    require 'eventbright'
    EventBright.setup("APP_KEY")
    user = EventBright::User.new("USER_KEY") #=> <EventBright::User >
    user.venues #=> [<EventBright::Venue>,...] # Venues the user has defined

Authentication
--------------
Many methods require user authentication. For these methods, you can pass a user object
as an authentication token, and the user's api_key will automatically be used for the
request. 

Example:
    
    EventBright::Event.new({"x" => "y"... , "user" => user})


A Note About App Keys
---------------------

This gem has an application key for accessing EventBrite, but each app key is limited to 30,000 requests a day. To make sure your limits aren't affected by others, you should register for your
own app key specific to the application you're adding the gem to. 

If you just want to give the gem a whirl (you have to wait for approval to get your own)
just don't call setup. The app key for the gem will be used.

Learn more about EventBrite's App Key policy here: [Terms of Service](http://www.eventbrite.com/api/terms)

Register for your own app key here: [Request a Key](http://www.eventbrite.com/api/key/)


API Inconsistencies:
--------------------

A list of sticking points for anyone attempting their own integration with EventBrite:

*/get => /update variable inconsistencies*

* event.id => event.event_id
* event.timezone (Olson format, ex: "America/New_York") => event.timezone (GMT offset hours, ex: "GMT-05")
* event.privacy (String representing privacy "Private"|"Public") => event.privacy (Boolean 0 = public)
* event.url => event.personalized_url
* venue.address => venue.adress
* venue.address_2 => venue.adress_2
* venue.name => venue.venue

*Fields you can't edit*

* event.category
* event.tags


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
