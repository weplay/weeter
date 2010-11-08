Weeter accepts a set of Twitter users to follow, and makes a POST to your app with each new tweet (or tweet deletion).

Getting set up
==============

    $ bundle install

Make a copy of the weeter.conf.example file named weeter.conf. Twitter configuration, client app configuration and weeter configuration are defined in separate
blocks. To configure how you connect to Twitter (basic auth or oauth), modify the twitter section of the configuration. 

To configure how weeter connects to your client app -- its (optional) authentication, and urls -- modify the client app configuration section:

* _subscriptions_url_: The URL at which to find JSON describing the Twitter users to follow (maximum 5,000 at the default API access level). Example content:
    `[{"twitter_user_id":"19466709"},{"twitter_user_id":"759251"}]`
* _publish_url_: The URL to which new tweets should be posted. Example POST body:
    `id=1111&twitter_user_id=19466709&text=Wassup`
* _delete_url_: The URL to which data about deleted tweets should be posted. Example DELETE body:
    `id=1111&twitter_user_id=19466709`

Weeter is configured to use 7337 as a default listening port.

Running weeter
==============

    $ bin/weeter_control start

This starts weeter as a daemon. For other commands and options, run:

    $ bin/weeter_control --help


Running specs
=============

    $ bundle exec rspec spec/

To Do
=====
- Error reporting
- Gemify
- Make tweet filtering strategy (re-tweets, replies, etc.) more flexible
- Add specs for client app proxy
- integration tests

