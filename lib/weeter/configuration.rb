require "singleton"

module Weeter

  class Configuration
    include Singleton

    attr_accessor :publish_url, :delete_url, :subscriptions_url, :listening_port, :basic_auth, :oauth, :log_path

    def listening_port
      @listening_port || 7337
    end

    def log_path
      @log_path || File.join(File.dirname(__FILE__), '..', '..', 'log', 'weeter.log')
    end
  end
end