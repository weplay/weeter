#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'em-http'
require 'evma_httpserver'
require 'json'
require 'twitter/json_stream'

TWITTER_USERNAME = ''
TWITTER_PASSWORD = ''
NEW_TWEET_URL    = ''
TWITTER_USER_URL = ''

class TweetStreamer

  def self.connect(ids)
    new.tap {|streamer| streamer.connect(ids) }
  end

  def connect(ids)
    @stream = Twitter::JSONStream.connect(
      :auth => "#{TWITTER_USERNAME}:#{TWITTER_PASSWORD}",
      :content => "follow=#{ids.join(',')}",
      :method => 'POST'
    )

    @stream.each_item do |item|
      parsed_item = JSON.parse(item)
      puts "GOT: #{parsed_item['text']}"

      EM::HttpRequest.new(NEW_TWEET_URL).post :body => {
        :id => parsed_item['id_str'],
        :text => parsed_item['text'],
        :twitter_user_id => parsed_item['user']['id_str']
      }
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

class TweetServer < EM::Connection
  include EM::HttpServer
  attr_accessor :streamer

  def process_http_request
    ids = JSON.parse(@http_post_content)
    streamer.reconnect(ids)
    EM::DelegatedHttpResponse.new(self).send_response
  end
end

initial_user_ids = []

EM.run {
  http = EM::HttpRequest.new(TWITTER_USER_URL).get
  http.callback {
    initial_user_ids = JSON.parse(http.response).map {|h| h['twitter_user_id'] } if http.response_header.status == 200
    EM.stop
  }
}

EM.run {
  streamer = TweetStreamer.connect(initial_user_ids)

  EM.start_server('localhost', 8080, TweetServer) {|conn| conn.streamer = streamer }

  trap('TERM') { EM.stop if EM.reactor_running? }
}
