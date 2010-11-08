require 'spec_helper'

describe Weeter::Configuration do
  it "should default listening_port" do
    Weeter::Configuration.instance.listening_port.should == 7337
  end

  describe "ClientAppConfiguration" do
    %w{delete_url subscriptions_url oauth}.each do |setting|
      it "should accept setting for #{setting}" do
        Weeter.configure do |conf|
          conf.client_app do |app|
            app.send("#{setting}=", "testvalue")
          end
        end
        Weeter::ClientAppConfiguration.instance.send(setting).should == "testvalue"
      end
    end
  end

  describe "TwitterConfiguration" do
    %w{basic_auth oauth}.each do |setting|
      it "should accept setting for #{setting}" do
        Weeter.configure do |conf|
          conf.twitter do |app|
            app.send("#{setting}=", "testvalue")
          end
        end
        Weeter::TwitterConfiguration.instance.send(setting).should == "testvalue"
      end
    end
    
    describe "auth_options" do
      
      before do
        Weeter::TwitterConfiguration.instance.oauth = nil
        Weeter::TwitterConfiguration.instance.basic_auth = nil
      end
      
      it "should return the oauth settings with a oauth credentials" do
        Weeter::TwitterConfiguration.instance.oauth = {:consumer_key => 'consumer_key', :consumer_secret => 'consumer_secret', :access_key => 'acces_key', :access_secret => 'access_secret'}
        Weeter::TwitterConfiguration.instance.auth_options.should == {:oauth => {:consumer_key => 'consumer_key', :consumer_secret => 'consumer_secret', :access_key => 'acces_key', :access_secret => 'access_secret'}}
      end
      
      it "should return the basic auth settings separated by a colon" do
        Weeter::TwitterConfiguration.instance.basic_auth = {:username => "bob", :password => "s3cr3t"}
        Weeter::TwitterConfiguration.instance.auth_options.should == {:auth => "bob:s3cr3t"}
      end
    
      it "should prefer oauth over basic auth" do
        Weeter::TwitterConfiguration.instance.basic_auth = {:username => "bob", :password => "s3cr3t"}
        Weeter::TwitterConfiguration.instance.oauth = {:consumer_key => 'consumer_key', :consumer_secret => 'consumer_secret', :access_key => 'acces_key', :access_secret => 'access_secret'}
        Weeter::TwitterConfiguration.instance.auth_options.should == {:oauth => {:consumer_key => 'consumer_key', :consumer_secret => 'consumer_secret', :access_key => 'acces_key', :access_secret => 'access_secret'}}
      end
    end
  end

end