require 'spec_helper'

describe Weeter::TweetItem do

  describe "deletion?" do
    it "should be true if it is a deletion request" do
      item = Weeter::TweetItem.new({"delete"=>{"status"=>{"id"=>234, "user_id"=>34555}}})
      item.should be_deletion
    end

    it "should be false if it is not a deletion request" do
      item = Weeter::TweetItem.new({'text' => "Hey", 'id_str' => "123", 'user' => {'id_str' => "1"}})
      item.should_not be_deletion
    end
  end

  describe "publishable" do

    before do
      @tweet_json = {'text' => "Hey", 'id_str' => "123", 'user' => {'id_str' => '1'}}
    end

    it "should be publishable if not a reply or a retweet" do
      item = Weeter::TweetItem.new(@tweet_json)
      item.should be_publishable
    end

    it "should be true if implicitly retweeted" do
      item = Weeter::TweetItem.new(@tweet_json.merge({'text' => 'RT @joe Hey'}))
      item.should_not be_publishable
    end

    it "should be true if explicitly retweeted" do
      item = Weeter::TweetItem.new(@tweet_json.merge('retweeted_status' => {'id_str' => '111', 'text' => 'Hey', 'user' => {'id_str' => "1"}}))
      item.should_not be_publishable
    end

    it "should be true if implicit reply" do
      item = Weeter::TweetItem.new(@tweet_json.merge('text' => '@joe Hey'))
      item.should_not be_publishable
    end

    it "should be true if explicit reply" do
      item = Weeter::TweetItem.new(@tweet_json.merge('text' => '@joe Hey', 'in_reply_to_user_id_str' => '1'))
      item.should_not be_publishable
    end

  end

  describe "json attributes" do

    it "should delegate hash calls to its json" do
      item = Weeter::TweetItem.new({'text' => "Hey"})
      item['text'].should == "Hey"
    end

    it "should retrieve nested attributes" do
      item = Weeter::TweetItem.new({'text' => "Hey", 'id_str' => "123", 'user' => {'id_str' => '1'}})
      item['user']['id_str'].should == "1"
    end

  end



end