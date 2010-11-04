require "singleton"

module Weeter
  
  def self.configure
    yield Configuration.instance
  end
  
  class Configuration
    include Singleton
    
    attr_accessor :publish_url, :delete_url, :subscriptions_url, :listening_port, :username, :password
    
    def listening_port
      @listening_port || 7337
    end
    
  end
end