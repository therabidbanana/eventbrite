require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventBright::ApiObjectCollection do
  before(:all) do
    module EventBright
      class Banana < ApiObject; readable :val; end
      class BananaBunch < ApiObjectCollection
        collection_for Banana
      end
      class Brady < ApiObject; end
      class BradyBunch < ApiObjectCollection
        collection_for Brady
        singlet_name "bob"
        plural_name "joe"
      end
    end
  end
  it "should have a singlet name same as class name" do
    EventBright::BananaBunch.singlet_name.should == 'banana'
    EventBright::BradyBunch.singlet_name.should == 'bob'
  end
  it "should add an s to the singlet name to get the plural" do
    EventBright::BananaBunch.plural_name.should == 'bananas'
    EventBright::BradyBunch.plural_name.should == 'joe'
  end
  it "should map an array of values on initialization" do
    b = EventBright::BananaBunch.new(false, ["banana" => {:val => 1}, "banana" => {:val => 2}])
    b
  end
  
end