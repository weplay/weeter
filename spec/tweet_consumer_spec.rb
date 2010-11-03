require 'spec_helper'

describe Weeter::TweetConsumer do
  before(:each) do
    @ids = [1,2,3]
    @consumer = Weeter::TweetConsumer.new(:username => 'joe', :password => 'schmoe', :publish_url => 'http://mysite.co')
    @mock_stream = mock('JSONStream', :each_item => nil, :on_error => nil, :on_max_reconnects => nil)
    Twitter::JSONStream.stub!(:connect).and_return(@mock_stream)
    @mock_request = mock('HttpRequest')
    EM::HttpRequest.stub!(:new).and_return(@mock_request)
    @mock_item = {:text => "Hey", :id_str => "123", :user => {:id_str => "1"}}
  end
  
  after(:each) do
    @consumer.connect(@ids)
  end
  
  it "should connect to a Twitter JSON stream" do
    Twitter::JSONStream.should_receive(:connect).
      with(:auth => "joe:schmoe", :content => "follow=#{@ids.join(',')}", :method => 'POST')
  end
  
  it "should publish new tweet" do
    @mock_stream.stub!(:each_item).and_yield(@mock_item.to_json)
    EM::HttpRequest.should_receive(:new).with('http://mysite.co').and_return(@mock_request)
    @mock_request.should_receive(:post).with(:body => {:id => '123', :text => 'Hey', :twitter_user_id => '1'})
  end

  describe "exclusion rules" do
    it "should not publish explicit re-tweet by non-followed user" do
      @mock_item = @mock_item.merge(:user => {:id_str => '11'}, :retweeted_status => {:id_str => '111', :text => 'Hey', :user => {:id_str => "1"}})
      @mock_stream.stub!(:each_item).and_yield(@mock_item.to_json)
      @mock_request.should_receive(:post).never
    end

    it "should not publish explicit re-tweet by followed user" do
      @mock_item = @mock_item.merge(:user => {:id_str => '1'}, :retweeted_status => {:id_str => '111', :text => 'Hey', :user => {:id_str => "11"}})
      @mock_stream.stub!(:each_item).and_yield(@mock_item.to_json)
      @mock_request.should_receive(:post).never
    end
    
    it "should not publish implicit re-tweet by followed user" do
      @mock_item = @mock_item.merge(:user => {:id_str => '1'}, :text => 'RT @joe Hey')
      @mock_stream.stub!(:each_item).and_yield(@mock_item.to_json)
      @mock_request.should_receive(:post).never
    end
    
    it "should not publish explicit replies to a followed user" do
      @mock_item = @mock_item.merge(:user => {:id_str => '11'}, :text => '@joe Hey', :in_reply_to_user_id_str => '1')
      @mock_stream.stub!(:each_item).and_yield(@mock_item.to_json)
      @mock_request.should_receive(:post).never
    end
    
    it "should not publish implicit replies to a followed user" do
      @mock_item = @mock_item.merge(:user => {:id_str => '11'}, :text => '@joe Hey')
      @mock_stream.stub!(:each_item).and_yield(@mock_item.to_json)
      @mock_request.should_receive(:post).never
    end
    
    it "should not publish replies by a followed user" do
      @mock_item = @mock_item.merge(:text => '@john Hey')
      @mock_stream.stub!(:each_item).and_yield(@mock_item.to_json)
      @mock_request.should_receive(:post).never
    end
  end
  
end