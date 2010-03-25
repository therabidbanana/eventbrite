eventbright
-----------

A simple library for integrating with EventBrite's API. Requires the "crack" gem for XML parsing.

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

Learn more about EventBrite's App Key policy here: "Terms of Service":http://www.eventbrite.com/api/terms

Register for your own app key here: "Request a Key":http://www.eventbrite.com/api/key/


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
