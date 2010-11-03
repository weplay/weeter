require 'spec_helper'

describe Weeter::Server do
  before(:each) do
    @new_ids = [1,2,3]
    @tweet_consumer = mock('TweetConsumer', :reconnect => nil)
    @tweet_server = Weeter::Server.new(nil)
    @tweet_server.instance_variable_set('@http_post_content', @new_ids.to_json)
    @tweet_server.tweet_consumer = @tweet_consumer
    @response = mock('DelegatedHttpResponse', :send_response => nil)
    EM::DelegatedHttpResponse.stub!(:new).and_return(@response)
  end
  
  after(:each) do
    @tweet_server.process_http_request
  end
  
  it "should process http request" do
    @tweet_consumer.should_receive(:reconnect).with(@new_ids)
  end
  
  it "should send response" do
    @response.should_receive(:send_response)
  end
end