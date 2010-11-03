require 'spec_helper'

describe Weeter::TweetConsumer do
  before(:each) do
    @ids = [1,2,3]
    @consumer = Weeter::TweetConsumer.new(:username => 'joe', :password => 'schmoe', :publish_url => 'http://mysite.co')
    @mock_stream = mock('JSONStream', :each_item => nil, :on_error => nil, :on_max_reconnects => nil)
    Twitter::JSONStream.stub!(:connect).and_return(@mock_stream)
    @mock_request = mock('HttpRequest')
    EM::HttpRequest.stub!(:new).and_return(@mock_request)
    @mock_item = {:text => "Hey", :id_str => "123", :user => {:id_str => "456"}}.to_json
  end
  
  after(:each) do
    @consumer.connect(@ids)
  end
  
  it "should connect to a Twitter JSON stream" do
    Twitter::JSONStream.should_receive(:connect).
      with(:auth => "joe:schmoe", :content => "follow=#{@ids.join(',')}", :method => 'POST')
  end
  
  it "should publish new tweet" do
    @mock_stream.stub!(:each_item).and_yield(@mock_item)
    EM::HttpRequest.should_receive(:new).with('http://mysite.co').and_return(@mock_request)
    @mock_request.should_receive(:post).with(:body => {:id => '123', :text => 'Hey', :twitter_user_id => '456'})
  end
end