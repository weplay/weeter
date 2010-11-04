require 'em-http'
require 'twitter/json_stream'

module Weeter
  class TweetConsumer

    def initialize(options = {})
      @username = options[:username]
      @password = options[:password]
      @publish_url = options[:publish_url]
      @delete_url = options[:delete_url]
    end

    def connect(ids)
      @stream = Twitter::JSONStream.connect(
        :auth => "#{@username}:#{@password}",
        :content => "follow=#{ids.join(',')}",
        :method => 'POST'
      )

      @stream.each_item do |item|
        tweet_item = TweetItem.new(JSON.parse(item))
        
        if tweet_item.deletion?
          EM::HttpRequest.new(@delete_url).delete :body => {
            :id => tweet_item['delete']['status']['id'].to_s,
            :twitter_user_id => tweet_item['delete']['status']['user_id'].to_s
          }
        elsif tweet_item.publishable?
          EM::HttpRequest.new(@publish_url).post :body => {
            :id => tweet_item['id_str'],
            :text => tweet_item['text'],
            :twitter_user_id => tweet_item['user']['id_str']
          }
        end
      end

      @stream.on_error {|msg| puts("ERROR: #{msg.inspect}") }

      @stream.on_max_reconnects {|timeout, retries| puts("MAX_RECONNECTS: #{{:timeout => timeout, :retries => retries}.inspect}") }
    end

    def reconnect(ids)
      @stream.stop
      puts "Reconnecting with ids: #{ids.inspect}"
      connect(ids)
    end

  end
end