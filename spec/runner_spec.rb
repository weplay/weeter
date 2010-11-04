require 'spec_helper'

describe Weeter::Runner do
  describe 'start' do
    before :each do
      @consumer = mock(:tweet_consumer, :connect => nil)

      EM.should_receive(:run).twice.and_yield
      EM.stub!(:start_server)

      http = mock(:http, :callback => nil)
      http_request = mock(:http_request, :get => http)
      EM::HttpRequest.stub!(:new => http_request)

      Weeter::Configuration.instance.oauth = nil
      Weeter::Configuration.instance.basic_auth = nil
    end

    describe 'when using oauth' do
      it 'should use a tweet consumer created with oauth authentication_options' do
        oauth_params = {:consumer_key => 'consumer_key', :consumer_secret => 'consumer_secret',
                       :access_key => 'acces_key', :access_secret => 'access_secret'}

        Weeter::Configuration.instance.oauth = oauth_params
        runner = Weeter::Runner.new(Weeter::Configuration.instance)

        Weeter::TweetConsumer.should_receive(:new).with(hash_including(:authentication_options => {:oauth => oauth_params})).and_return(@consumer)

        runner.start
      end

      it "should prefer oauth over basic auth" do
        oauth_params = {:consumer_key => 'consumer_key', :consumer_secret => 'consumer_secret',
                       :access_key => 'acces_key', :access_secret => 'access_secret'}

        Weeter::Configuration.instance.oauth = oauth_params
        Weeter::Configuration.instance.basic_auth = {:username => 'foo', :password => 'bar'}
        runner = Weeter::Runner.new(Weeter::Configuration.instance)

        Weeter::TweetConsumer.should_receive(:new).with(hash_including(:authentication_options => {:oauth => oauth_params})).and_return(@consumer)
        runner.start
      end

    end

    describe 'when using basic auth' do
      it 'should use a tweet consumer created with basic_auth authentication_options' do
        Weeter::Configuration.instance.basic_auth = {:username => 'foo', :password => 'bar'}
        runner = Weeter::Runner.new(Weeter::Configuration.instance)

        Weeter::TweetConsumer.should_receive(:new).with(hash_including(:authentication_options => {:auth => 'foo:bar'})).and_return(@consumer)

        runner.start
      end
    end
  end
end