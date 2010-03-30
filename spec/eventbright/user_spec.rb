require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventBright::User do
  before(:all) do
    EventBright.setup("key")
  end
  
  it "should load from API on initialization" do
    EventBright::API.should_receive(:do_post).with("/user_get", anything).and_return(fake_response("/user_get"))
    u = EventBright::User.new("fake_key")
    u.attribute_get(:email).should == "david@orangesparkleball.com"
    u.attribute_get(:password).should be_nil
    u.attribute_get(:user_key).should_not be_nil
  end
  
  it "should not call API if no_load set in initialization" do
    EventBright::API.should_not_receive(:do_post)
    EventBright::User.new("fake_key", true)
  end
  
  it "should accept an array of [email, password] as authentication" do
    EventBright::API.should_receive(:do_post).with("/user_get", :body => hash_including("password", "user")).and_return(fake_response("/user_get"))
    u = EventBright::User.new(["fake_user", "fake_pass"])
    u.attribute_get(:email).should_not be_nil
  end
  
  it "should return a user auth hash" do
    u = EventBright::User.new("fake_key", true)
    u2 = EventBright::User.new(["fake_email", "fake_pass"], true)
    u.auth.should_not == u2.auth
    u.auth["user_key"].should_not be_nil
    u2.auth["user_key"].should be_nil
    u.auth["user"].should be_nil
    u2.auth["user"].should_not be_nil
  end
  
  it "should retrieve venues" do
    u = EventBright::User.new("fake_key", true)
    EventBright::API.should_receive(:do_post).with("/user_list_venues", anything).and_return(fake_response("/user_list_venues"))
    v = u.venues
    v.should be_an EventBright::VenueCollection
    v.should_not be_empty
  end
  
  it "should cache venues" do
    u = EventBright::User.new("fake_key", true)
    EventBright::API.should_receive(:do_post).once.with("/user_list_venues", anything).and_return(fake_response("/user_list_venues"))
    u.venues
    u.venues
    EventBright::API.should_receive(:do_post).once.with("/user_list_venues", anything).and_return(fake_response("/user_list_venues"))
    u.dirty_venues!
    u.venues
  end
  
  it "should retrieve organizers" do
    u = EventBright::User.new("fake_key", true)
    EventBright::API.should_receive(:do_post).with("/user_list_organizers", anything).and_return(fake_response("/user_list_organizers"))
    o = u.organizers
    o.should be_an EventBright::OrganizerCollection
    o.should_not be_empty
  end
  
  it "should cache organizers" do
    u = EventBright::User.new("fake_key", true)
    EventBright::API.should_receive(:do_post).once.with("/user_list_organizers", anything).and_return(fake_response("/user_list_organizers"))
    u.organizers
    u.organizers
    EventBright::API.should_receive(:do_post).once.with("/user_list_organizers", anything).and_return(fake_response("/user_list_organizers"))
    u.dirty_organizers!
    u.organizers
  end
  
  it "should retrieve events" do
    u = EventBright::User.new("fake_key", true)
    EventBright::API.should_receive(:do_post).with("/user_list_events", anything).and_return(fake_response("/user_list_events"))
    e = u.events
    e.should be_an EventBright::EventCollection
    e.should_not be_empty
  end
  
  it "should cache events" do
    u = EventBright::User.new("fake_key", true)
    EventBright::API.should_receive(:do_post).once.with("/user_list_events", anything).and_return(fake_response("/user_list_events"))
    u.events
    u.events
    EventBright::API.should_receive(:do_post).once.with("/user_list_events", anything).and_return(fake_response("/user_list_events"))
    u.dirty_events!
    u.events
  end
  
  it "should call init_with_hash and call API if calling load" do
    u = EventBright::User.new("fake_key", true)
    EventBright::API.should_receive(:do_post).with("/user_get", anything).and_return(fake_response("/user_get"))
    u.should_receive(:init_with_hash).with(instance_of(Hash), anything)
    u.load
  end
  
  it "should get an init_with_hash method" do
    u = EventBright::User.new("fake_key", true)
    h = fake_response("/user_get")["user"]
    u.init_with_hash(h)
    u.email.should_not be_nil
  end
  
  it "should load attributes when calling load" do
    u = EventBright::User.new("fake_key", true)
    u.email.should be_nil
    u.load
    u.email.should_not be_nil
  end
  
  it "should have a dirty-tracking update hash" do
    u = EventBright::User.new("fake_key", true)
    u.updatable_hash.should be_empty
    u.load!
    u.updatable_hash.size.should == 1
    u.updatable_hash[:id].should_not be_nil
    u.email = "foo"
    u.updatable_hash.size.should == 2
    u.updatable_hash[:email].should_not be_nil
  end
  
  it "should track loaded status" do
    u = EventBright::User.new("fake_key", true)
    u.loaded?.should be_false
    u.load
    u.loaded?.should be_true
  end
  
  it "should track dirty status" do
    u = EventBright::User.new("fake_key", true)
    # Can't be clean until we load
    u.dirty?.should be_true
    u.load!
    u.dirty?.should be_false
    u.date_modified = "now"
    u.dirty?.should be_false
    u.email = "banana"
    u.dirty?.should be_true
  end
end
