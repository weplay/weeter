require 'em-http'

module Weeter
  class Runner

    def initialize(config)
      @config = config
      Weeter.logger.info("Starting weeter with configuration: #{@config.inspect}")
    end

    def start
      initial_ids = get_initial_ids

      EM.run {
        tweet_consumer.connect(initial_ids)

        EM.start_server('localhost', @config.listening_port, Weeter::Server) do |conn|
          conn.tweet_consumer = tweet_consumer
        end

        trap('TERM') do
          Weeter.logger.info("Stopping weeter")
          EM.stop if EM.reactor_running?
        end
      }
    end

  protected

    def tweet_consumer
      @tweet_consumer ||= Weeter::TweetConsumer.new(
        :authentication_options => authentication_options,
        :publish_url => @config.publish_url,
        :delete_url => @config.delete_url
      )
    end

    def authentication_options
      if @config.twitter_oauth
        {:oauth => @config.twitter_oauth}
      else
        username = @config.twitter_basic_auth[:username]
        password = @config.twitter_basic_auth[:password]
        {:auth => "#{username}:#{password}"}
      end
    end

    def get_initial_ids
      initial_ids = []
      EM.run {
        http = EM::HttpRequest.new(@config.subscriptions_url).get
        http.callback {
          if http.response_header.status == 200
            initial_ids = JSON.parse(http.response).map {|h| h['twitter_user_id'] }
          else
            Weeter.logger.error "Initial ID request failed with response code #{http.response_header.status}."
          end
          EM.stop
        }
      }
      initial_ids
    end

  end
end
