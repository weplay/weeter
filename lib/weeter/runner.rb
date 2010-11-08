require 'em-http'

module Weeter
  class Runner

    def initialize(config)
      @config = config
      Weeter.logger.info("Starting weeter with configuration: #{@config.inspect}")
    end

    def start
      EM.run {
        client_app_proxy.get_initial_ids do |initial_ids|
          tweet_consumer.connect(initial_ids)

          EM.start_server('localhost', @config.listening_port, Weeter::Server) do |conn|
            conn.tweet_consumer = tweet_consumer
          end

          trap('TERM') do
            Weeter.logger.info("Stopping weeter")
            EM.stop if EM.reactor_running?
          end
        end
      }
    end

  protected

    def client_app_proxy
      @client_app_proxy ||= Weeter::ClientAppProxy.new(ClientAppConfiguration.instance)
    end
    
    def tweet_consumer
      @tweet_consumer ||= Weeter::TweetConsumer.new(TwitterConfiguration.instance, client_app_proxy)
    end
  end
end
