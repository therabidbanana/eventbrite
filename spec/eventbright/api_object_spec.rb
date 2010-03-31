require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/api_object_class_spec')
require File.expand_path(File.dirname(__FILE__) + '/api_object_relationship_spec')
describe EventBright::ApiObject do
  before(:all) do
    
  end
  describe "class methods" do
    it_should_behave_like "EventBright::ApiObject class methods"
  end
  describe "relationships" do
    it_should_behave_like "EventBright::ApiObject relationship methods"
  end
  
end