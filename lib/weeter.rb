require 'eventmachine'
require 'json'
require 'logger'

require 'weeter/configuration'
require 'weeter/cli'
require 'weeter/client_app_proxy'
require 'weeter/server'
require 'weeter/tweet_item'
require 'weeter/tweet_consumer'
require 'weeter/runner'


module Weeter
  
  def self.configure
    yield Configuration.instance
  end
  
  def self.logger
    @logger ||= Logger.new(Configuration.instance.log_path)
  end
end