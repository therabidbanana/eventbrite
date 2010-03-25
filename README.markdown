eventbright
-----------

A simple library for integrating with EventBrite's API. Requires the "crack" gem for XML parsing.

Usage
-----

    require 'eventbright'
    EventBright.setup("APP_KEY")

This gem has an application key for accessing EventBrite, but each app key is limited to 30,000 requests a day. To make sure your limits aren't affected by others, you should register for your
own app key specific to the application you're adding the gem to. If you just want to give it
a whirl though, you can use the gem's app_key by calling setup without any arguments (this is useful since each app key requires ) 




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
