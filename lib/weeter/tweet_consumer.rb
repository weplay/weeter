require 'twitter/json_stream'

module Weeter
  class TweetConsumer

    def initialize(twitter_config, client_app)
      @config = twitter_config
      @client_app = client_app
    end

    def connect(ids)
      connect_options = {:params => {:follow => ids}, :method => 'POST'}.merge(@config.auth_options)
      @stream = Twitter::JSONStream.connect(connect_options)

      @stream.each_item do |item|
        begin
          tweet_item = TweetItem.new(JSON.parse(item))

          if tweet_item.deletion?
            @client_app.delete_tweet(tweet_item)
          elsif tweet_item.publishable?
            @client_app.publish_tweet(tweet_item)
          else
            ignore_tweet(tweet_item)
          end
        rescue => ex
          Weeter.logger.error("Twitter stream tweet exception: #{ex.class.name}: #{ex.message}")
        end
      end

      @stream.on_error do |msg|
        Weeter.logger.error("Twitter stream error: #{msg}")
      end

      @stream.on_max_reconnects do |timeout, retries|
        Weeter.logger.error("Twitter stream max-reconnects reached: timeout=#{timeout}, retries=#{retries}")
      end
    end

    def reconnect(ids)
      @stream.stop
      connect(ids)
    end

  protected

    def ignore_tweet(tweet_item)
      id = tweet_item['id_str']
      text = tweet_item['text']
      user_id = tweet_item['user']['id_str']
      Weeter.logger.info("Ignoring tweet #{id} from user #{user_id}: #{text}")
    end

  end
end