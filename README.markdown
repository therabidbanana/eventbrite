eventbright
================

A simple library for integrating with EventBrite's API. Requires the "httparty" gem for connecting and doing XML parsing, and "tzinfo" gem for getting back and forth between timezone names and GMT offsets.

Usage
-----

    require 'eventbright'
    EventBright.setup("APP_KEY")
    user = EventBright::User.new("USER_KEY") #=> <EventBright::User >
    user.venues #=> [<EventBright::Venue>,...] # Venues the user has defined

Authentication
--------------
Many methods require user authentication. For these methods, you can pass a user object as an authentication token, and the user's api_key will automatically be used for the request. 

Example:
    
    EventBright::Event.new({"x" => "y"... , "user" => user})

Known Bugs
----------

1. This library has no specs. I tested everything in IRB. :(

A Note About App Keys
---------------------

This gem has an application key for accessing EventBrite, but each app key is limited to 30,000 requests a day. To make sure your limits aren't affected by others, you should register for your own app key specific to the application you're adding the gem to. 

If you just want to give the gem a whirl (you have to wait for approval to get your own) just don't call setup. The app key for the gem will be used.

Learn more about EventBrite's App Key policy here: [Terms of Service](http://www.eventbrite.com/api/terms)

Register for your own app key here: [Request a Key](http://www.eventbrite.com/api/key/)


API Gotchas:
--------------------

A list of sticking points for anyone attempting their own integration with the EventBrite API:

__/get => /update variable inconsistencies__

* event.id => event.event_id
* event.timezone (Olson format, ex: "US/Central") => event.timezone (GMT offset hours, ex: "GMT-05")
* event.privacy (String representing privacy "Private"|"Public") => event.privacy (Boolean 0 = public)
* event.url => event.personalized_url
* venue.address => venue.adress
* venue.address_2 => venue.adress_2
* venue.name => venue.venue
* event.tickets.ticket.start_date => ticket.start_sales
* event.tickets.ticket.end_date => ticket.end_sales
* event.tickets.ticket.visible (1 is visible) => ticket.hide (y is hidden, n is visible)
* event.tickets.ticket.quantity_available => ticket.quantity

__Fields you can't edit__

* event.category
* event.tags
* event.logo
* ticket.hide (on /ticket_new. You must save the ticket then call /ticket_update to hide)

__Documentation errors__

* /venue_new and /venue_update does not throw an error if "venue" is invalid/non-unique/empty.
* Dates are not technically ISO 8601 (ISO 8601 specifies a "T" - not a space - between date and time, so passing perfectly formatted ISO 8601 datetime strings such as those a standard library would provide will cause errors)
* Error description for event Privacy Error: <pre>"The privacy field must be equal to 0 (public) or 1 (private)"</pre> -> This is the opposite of the actual case. 0 is private and 1 is public, as described in other places within the API.
* /ticket_new and /ticket_update do not throw errors if quantity not set

__Other gotchas__

* Venue object included in event has extra "Lat-Long" attribute, along with "latitude" and "longitude". If you're turning a result into an object, this might cause an error if you don't suspect it.
* Timezones are weird (nothing EventBrite can do about this one): GMT offset for timezones is always computed in standard time (don't adjust for Daylight Savings, unlike UTC offset). This weirdness means that once you save the timezone the Olson description might not match what you think it should (ex. US/Eastern becomes GMT-5 which then becomes America/Bogota)

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
