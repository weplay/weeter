module Weeter

  class TweetItem
    def initialize(json)
      @tweet_json = json
    end

    def deletion?
      !@tweet_json['delete'].nil?
    end
    
    def retweeted?
      !@tweet_json['retweeted_status'].nil? || @tweet_json['text'] =~ /^RT @/i
    end
    
    def reply?
      !@tweet_json['in_reply_to_user_id_str'].nil? || @tweet_json['text'] =~ /^@/
    end
    
    def publishable?
      !retweeted? && !reply?
    end
    
    def [](val)
      @tweet_json[val]
    end

  end

end