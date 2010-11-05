require 'em-http'

module Weeter
  class ClientAppProxy

    def initialize(client_app_config)
      @config = client_app_config
    end

    def get_initial_ids(&block)
      http = http_request(:get, @config.subscriptions_url)
      http.callback {
        initial_ids = []
        if http.response_header.status == 200
          initial_ids = JSON.parse(http.response).map {|h| h['twitter_user_id'] }
        else
          Weeter.logger.error "Initial ID request failed with response code #{http.response_header.status}."
        end
        yield initial_ids
      }
    end

    def delete_tweet(tweet_item)
      id = tweet_item['delete']['status']['id'].to_s
      user_id = tweet_item['delete']['status']['user_id'].to_s
      Weeter.logger.info("Deleting tweet #{id} for user #{user_id}")
      http_request(:delete, @config.delete_url, {:id => id, :twitter_user_id => user_id})
    end

    def publish_tweet(tweet_item)
      id = tweet_item['id_str']
      text = tweet_item['text']
      user_id = tweet_item['user']['id_str']
      Weeter.logger.info("Publishing tweet #{id} from user #{user_id}: #{text}")
      http_request(:post, @config.publish_url, {:id => id, :text => text, :twitter_user_id => user_id})
    end

  protected

    def http_request(method, url, params = {})
      if method == :get
        request_options = {:query => params}
      else
        request_options = {:body => params}
      end
      request_options.merge!(:head => {"Authorization" => oauth_header(url, params, method.to_s.upcase)}) if @config.oauth
      EM::HttpRequest.new(url).send(method, request_options)
    end

    def oauth_header(uri, params, http_method)
      ::ROAuth.header(@config.oauth, uri, params, http_method)
    end

  end
end