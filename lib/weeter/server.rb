require 'evma_httpserver'

module Weeter
  class Server < EM::Connection
    include EM::HttpServer
    attr_accessor :streamer

    def process_http_request
      ids = JSON.parse(@http_post_content)
      streamer.reconnect(ids)
      EM::DelegatedHttpResponse.new(self).send_response
    end
  end
end
