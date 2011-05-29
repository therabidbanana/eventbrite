require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Eventbrite do
  before(:each) do
    Eventbrite.setup("key")
  end
  it "should have setup method" do
    Eventbrite.should respond_to(:setup)
    lambda {
      Eventbrite.setup("key")
      Eventbrite.setup("key", true)
    }.should_not raise_error
  end
  it "should call httparty with key given to setup" do
    Eventbrite::API.should_receive(:do_post).with(anything, hash_including(:body => hash_including(:app_key => "key")))
    Eventbrite.call("event_get", {})
  end
  
  it "should have call method" do
    Eventbrite.should respond_to(:call)
  end
  it "should have debug! method" do
    Eventbrite.should respond_to(:debug!)
  end
    
  it "should replace a user object with a user_key on #call" do
    Eventbrite::API.should_receive(:do_post).with("/user_get", {:body => {:app_key => "key", "user_key" => "fake_key"}})
    Eventbrite.call(:user_get, :user => Eventbrite::User.new("fake_key", true))
  end
  
  it "should format time according to eventbrite's wrong iso8601" do
    a = "2010-04-01 13:37:00"
    b = Time.parse("4/1/2010 13:37")
    a.should == Eventbrite.formatted_time(b)
  end
end
