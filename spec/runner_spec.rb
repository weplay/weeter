require 'spec_helper'

describe Weeter::Runner do
  describe 'start' do
    before :each do
      @consumer = mock(:tweet_consumer, :connect => nil)

      EM.should_receive(:run).twice.and_yield
      EM.stub!(:start_server)

      @http = mock(:http, :callback => nil)
      @http_request = mock(:http_request, :get => @http)
      EM::HttpRequest.stub!(:new => @http_request)

      Weeter::Configuration.instance.twitter_oauth = nil
      Weeter::Configuration.instance.twitter_basic_auth = nil
    end

    describe "initial ids" do
      it "should use the subscriptions url to get the initial ids" do
        Weeter.configure do |config|
          config.twitter_oauth = {}
          config.subscriptions_url = "http://www.site.com/ids"
        end

        EM::HttpRequest.should_receive(:new).with("http://www.site.com/ids").and_return(@http_request)
        Weeter::TweetConsumer.stub!(:new).and_return(@consumer)

        runner = Weeter::Runner.new(Weeter::Configuration.instance)
        runner.start
      end
      
      it "should parse JSON in the response to get the IDS" do
        Weeter.configure do |config|
          config.twitter_oauth = {}
          config.subscriptions_url = "http://www.site.com/ids"
        end
        Weeter::TweetConsumer.stub!(:new).and_return(@consumer)
        @http = mock(:http, :response_header => mock(:header, :status => 200), :response => [{'twitter_user_id' => '44'}, {'twitter_user_id' => '33'}].to_json)
        @http.should_receive(:callback).and_yield
        @http_request = mock(:http_request, :get => @http)
        EM::HttpRequest.stub!(:new => @http_request)
        EM.stub!(:stop)
        
        runner = Weeter::Runner.new(Weeter::Configuration.instance)
        @consumer.should_receive(:connect).with(["44","33"])
        runner.start
      end
    end

    describe 'when using oauth' do
      it 'should use a tweet consumer created with oauth authentication_options' do
        oauth_params = {:consumer_key => 'consumer_key', :consumer_secret => 'consumer_secret',
                       :access_key => 'acces_key', :access_secret => 'access_secret'}

        Weeter::Configuration.instance.twitter_oauth = oauth_params
        runner = Weeter::Runner.new(Weeter::Configuration.instance)

        Weeter::TweetConsumer.should_receive(:new).with(hash_including(:twitter_auth_options => {:oauth => oauth_params})).and_return(@consumer)

        runner.start
      end

      it "should prefer oauth over basic auth" do
        oauth_params = {:consumer_key => 'consumer_key', :consumer_secret => 'consumer_secret',
                       :access_key => 'acces_key', :access_secret => 'access_secret'}

        Weeter::Configuration.instance.twitter_oauth = oauth_params
        Weeter::Configuration.instance.twitter_basic_auth = {:username => 'foo', :password => 'bar'}
        runner = Weeter::Runner.new(Weeter::Configuration.instance)

        Weeter::TweetConsumer.should_receive(:new).with(hash_including(:twitter_auth_options => {:oauth => oauth_params})).and_return(@consumer)
        runner.start
      end

    end

    describe 'when using basic auth' do
      it 'should use a tweet consumer created with basic_auth authentication_options' do
        Weeter::Configuration.instance.twitter_basic_auth = {:username => 'foo', :password => 'bar'}
        runner = Weeter::Runner.new(Weeter::Configuration.instance)

        Weeter::TweetConsumer.should_receive(:new).with(hash_including(:twitter_auth_options => {:auth => 'foo:bar'})).and_return(@consumer)

        runner.start
      end
    end
  end
end