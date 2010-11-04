require 'em-http'
require 'twitter/json_stream'

module Weeter
  class TweetConsumer

    def initialize(options = {})
      @publish_url = options[:publish_url]
      @delete_url = options[:delete_url]
      @authentication_options = options[:authentication_options]
    end

    def connect(ids)
      connect_options = {:params => {:follow => ids}, :method => 'POST'}.merge(@authentication_options)
      @stream = Twitter::JSONStream.connect(connect_options)

      @stream.each_item do |item|
        begin
          tweet_item = TweetItem.new(JSON.parse(item))

          if tweet_item.deletion?
            delete_tweet(tweet_item)
          elsif tweet_item.publishable?
            publish_tweet(tweet_item)
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

    def delete_tweet(tweet_item)
      id = tweet_item['delete']['status']['id'].to_s
      user_id = tweet_item['delete']['status']['user_id'].to_s
      Weeter.logger.info("Deleting tweet #{id} for user #{user_id}")
      EM::HttpRequest.new(@delete_url).delete :body => {:id => id, :twitter_user_id => user_id}
    end

    def publish_tweet(tweet_item)
      id = tweet_item['id_str']
      text = tweet_item['text']
      user_id = tweet_item['user']['id_str']
      Weeter.logger.info("Publishing tweet #{id} from user #{user_id}: #{text}")
      EM::HttpRequest.new(@publish_url).post :body => {:id => id, :text => text, :twitter_user_id => user_id}
    end

    def ignore_tweet(tweet_item)
      id = tweet_item['id_str']
      text = tweet_item['text']
      user_id = tweet_item['user']['id_str']
      Weeter.logger.info("Ignoring tweet #{id} from user #{user_id}: #{text}")
    end
  end
end