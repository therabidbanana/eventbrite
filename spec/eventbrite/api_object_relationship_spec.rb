share_examples_for "Eventbrite::ApiObject relationship methods" do
  before :all do
    @bar = Eventbrite::Bar.new
  end
  it "should be able to get relations" do
    @bar.relations.should == {}
    @bar.relations = {:banana => Eventbrite::Banana.new}
    @bar.banana.should be_an_instance_of(Eventbrite::Banana)
    @bar.relations.should have(1).items
    @bar.should_receive(:relation_get).with(:banana)
    lambda{
      @bar.banana
    }.should_not raise_error
  end
  it "should be able to get collections" do
    @bar.collections.should == {}
    @bar.collections = {:bananas => Eventbrite::BananaBunch.new}
    @bar.bananas.should be_an_instance_of(Eventbrite::BananaBunch)
    @bar.collections.should have(1).items
    @bar.should_receive(:collection_get).with(:bananas)
    lambda{@bar.bananas}.should_not raise_error
  end
end
