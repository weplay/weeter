Getting set up
==============

  $ bundle install


Running weeter
==============

Make a copy of the weeter.conf.example file named weeter.conf. Modify its values for your environment. Then:

  $ bin/weeter_control start

For other commands and options, run:

  $ bin/weeter_control --help


Running specs
=============

  $ bundle exec rspec spec/


To Do
=====

- Support OAuth instead of (or in addition to) basic authentication
- Maintain log file
- Error reporting
- Don't hard-code tweet filtering strategy (re-tweets, replies, etc.)
