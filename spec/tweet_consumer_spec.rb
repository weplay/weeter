require 'spec_helper'

describe Weeter::TweetConsumer do
  before(:each) do
    @ids = [1,2,3]
    @consumer = Weeter::TweetConsumer.new(:username => 'joe', :password => 'schmoe', :publish_url => 'http://mysite.co', :delete_url => 'http://mysite.co/delete')
    @mock_stream = mock('JSONStream', :each_item => nil, :on_error => nil, :on_max_reconnects => nil)
    Twitter::JSONStream.stub!(:connect).and_return(@mock_stream)
    @mock_request = mock('HttpRequest', :post => nil)
    EM::HttpRequest.stub!(:new).and_return(@mock_request)
    @tweet_values = {'text' => "Hey", 'id_str' => "123", 'user' => {'id_str' => "1"}}
    @mock_stream.stub!(:each_item).and_yield(@tweet_values.to_json)
  end
  
  after(:each) do
    @consumer.connect(@ids)
  end
  
  it "should instantiate a TweetItem" do
    tweet_item = Weeter::TweetItem.new(@tweet_values)
    Weeter::TweetItem.should_receive(:new).with({'text' => "Hey", 'id_str' => "123", 'user' => {'id_str' => "1"}}).and_return(tweet_item)
  end
  
  describe "publishable" do
    it "should connect to a Twitter JSON stream" do
      Twitter::JSONStream.should_receive(:connect).
        with(:auth => "joe:schmoe", :content => "follow=#{@ids.join(',')}", :method => 'POST')
    end

    it "should publish new tweet if publishable" do
      tweet_item = Weeter::TweetItem.new(@tweet_values)
      tweet_item.stub!(:publishable?).and_return(true)
      Weeter::TweetItem.stub!(:new).and_return(tweet_item)
      EM::HttpRequest.should_receive(:new).with('http://mysite.co').and_return(@mock_request)
      @mock_request.should_receive(:post).with(:body => {:id => '123', :text => 'Hey', :twitter_user_id => '1'})
    end
  end
  
  describe "not publishable" do
    it "should not publish non publishable tweets" do
      tweet_item = Weeter::TweetItem.new(@tweet_values)
      tweet_item.stub!(:publishable?).and_return(false)
      Weeter::TweetItem.stub!(:new).and_return(tweet_item)
      EM::HttpRequest.should_not_receive(:new)
    end
  end
  
  describe "deletion" do
    it "should respond to delete requests" do
      delete_values = {"delete"=>{"status"=>{"id"=>234, "user_id"=>34555}}}
      @mock_stream.stub!(:each_item).and_yield(delete_values.to_json)
      
      tweet_item = Weeter::TweetItem.new(delete_values)
      tweet_item.stub!(:deletion?).and_return(true)
      Weeter::TweetItem.stub!(:new).and_return(tweet_item)
      
      EM::HttpRequest.should_receive(:new).with('http://mysite.co/delete').and_return(@mock_request)
      @mock_request.should_receive(:delete).with(:body => {:id => '234', :twitter_user_id => '34555'})
    end
  end
  
end