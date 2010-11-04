require 'evma_httpserver'

module Weeter
  class Server < EM::Connection
    include EM::HttpServer
    attr_accessor :tweet_consumer

    def process_http_request
      Weeter.logger.info("Reconnecting Twitter stream")
      ids = JSON.parse(@http_post_content)
      tweet_consumer.reconnect(ids)
      EM::DelegatedHttpResponse.new(self).send_response
    end
  end
end
