require 'em-http'

module Weeter
  class Runner

    def initialize(config)
      @config = config
    end

    def start
      initial_ids = get_initial_ids

      EM.run {
        tweet_consumer.connect(initial_ids)

        EM.start_server('localhost', @config.listening_port, Weeter::Server) do |conn|
          conn.tweet_consumer = tweet_consumer
        end

        trap('TERM') { EM.stop if EM.reactor_running? }
      }
    end

  protected

    def tweet_consumer
      @tweet_consumer ||= Weeter::TweetConsumer.new(
        :username => @config.username,
        :password => @config.password,
        :publish_url => @config.publish_url
      )
    end

    def get_initial_ids
      initial_ids = []
      EM.run {
        http = EM::HttpRequest.new(@config.subscriptions_url).get
        http.callback {
          initial_ids = JSON.parse(http.response).map {|h| h['twitter_user_id'] } if http.response_header.status == 200
          EM.stop
        }
      }
      initial_ids
    end

  end
end