require 'em-http'
require 'twitter/json_stream'

module Weeter
  class TweetConsumer

    def initialize(options = {})
      @username = options[:username]
      @password = options[:password]
      @publish_url = options[:publish_url]
    end

    def connect(ids)
      @stream = Twitter::JSONStream.connect(
        :auth => "#{@username}:#{@password}",
        :content => "follow=#{ids.join(',')}",
        :method => 'POST'
      )

      @stream.each_item do |item|
        parsed_item = JSON.parse(item)

        if publish?(parsed_item)
          EM::HttpRequest.new(@publish_url).post :body => {
            :id => parsed_item['id_str'],
            :text => parsed_item['text'],
            :twitter_user_id => parsed_item['user']['id_str']
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
    
  protected
  
    def publish?(tweet)
      !retweeted?(tweet) && !reply?(tweet)
    end
    
    def retweeted?(tweet)
      tweet['retweeted_status'] || tweet['text'] =~ /^RT @/i
    end
    
    def reply?(tweet)
      tweet['in_reply_to_user_id_str'] || tweet['text'] =~ /^@/
    end
  end
end