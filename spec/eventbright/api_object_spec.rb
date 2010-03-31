require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe EventBright::ApiObject do
  before(:all) do
    
  end
  context "class methods" do
    it "should have a singlet name same as class name, or set singlet_name" do
      EventBright::Foo.singlet_name.should == 'foo'
      EventBright::Bar.singlet_name.should == 'baz'
    end
    it "should add an s to the singlet name to get the plural, or use set plural" do
      EventBright::Foo.plural_name.should == 'foos'
      EventBright::Bar.plural_name.should == 'bazzes'
    end
    
  end
  
end