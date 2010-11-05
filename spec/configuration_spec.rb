require 'spec_helper'

describe Weeter::Configuration do
  it "should default listening_port" do
    Weeter::Configuration.instance.listening_port.should == 7337
  end

  %w{twitter_oauth twitter_basic_auth publish_url delete_url subscriptions_url listening_port oauth}.each do |setting|
    it "should accept setting for #{setting}" do
      Weeter.configure do |conf|
        conf.send("#{setting}=", "testvalue")
      end
      Weeter::Configuration.instance.send(setting).should == "testvalue"
    end
  end
end