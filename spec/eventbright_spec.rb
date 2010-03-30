require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe EventBright do
  before(:each) do
    EventBright.setup("key")
  end
  it "should have setup method" do
    EventBright.should respond_to(:setup)
    lambda {
      EventBright.setup("key")
      EventBright.setup("key", true)
    }.should_not raise_error
  end
  it "should call httparty with key given to setup" do
    EventBright::API.should_receive(:do_post).with(anything, hash_including(:body => hash_including(:app_key => "key")))
    EventBright.call("event_get", {})
  end
  
  it "should have call method" do
    EventBright.should respond_to(:call)
  end
  it "should have debug! method" do
    EventBright.should respond_to(:debug!)
  end
    
  it "should replace a user object with a user_key on #call" do
    EventBright::API.should_receive(:do_post).with("/user_get", {:body => {:app_key => "key", "user_key" => "fake_key"}})
    EventBright.call(:user_get, :user => EventBright::User.new("fake_key", true))
  end
  
  
end
