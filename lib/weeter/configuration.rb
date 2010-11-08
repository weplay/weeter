require "singleton"

module Weeter

  class TwitterConfiguration
    include Singleton
    attr_accessor :basic_auth, :oauth
    
    def auth_options
      if oauth
        {:oauth => oauth}
      else
        username = basic_auth[:username]
        password = basic_auth[:password]
        {:auth => "#{username}:#{password}"}
      end
    end
  end
  
  class ClientAppConfiguration
    include Singleton
    attr_accessor :publish_url, :delete_url, :subscriptions_url, :oauth
  end

  class Configuration
    include Singleton
    attr_accessor :listening_port, :log_path

    def twitter
      yield TwitterConfiguration.instance
    end
    
    def client_app
      yield ClientAppConfiguration.instance
    end
    
    def listening_port
      @listening_port || 7337
    end

    def log_path
      @log_path || File.join(File.dirname(__FILE__), '..', '..', 'log', 'weeter.log')
    end
  end
end