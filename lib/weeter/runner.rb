require 'em-http'

module Weeter
  class Runner
    
    def initialize(options = {})
      @twitter_user_url = options[:twitter_user_url]
      @port = options[:port] || 7337
    end
    
    def start
      EM.run {
        http = EM::HttpRequest.new(@twitter_user_url).get
        http.callback {
          initial_user_ids = JSON.parse(http.response).map {|h| h['twitter_user_id'] } if http.response_header.status == 200
          EM.stop
        }
      }

      EM.run {
        streamer = Weeter::TweetConsumer.connect(initial_user_ids)

        EM.start_server('localhost', @port, Weeter::Server) {|conn| conn.streamer = streamer }

        trap('TERM') { EM.stop if EM.reactor_running? }
      }
    end

  end
end