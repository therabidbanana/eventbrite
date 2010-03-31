require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventBright::ApiObjectCollection do
  before(:all) do
    @b = EventBright::BananaBunch.new(false, [{"banana" => {:val => 1}}, {"banana" => {:val => 2}}])
  end
  context "collection functions" do
    it "should pass through standard Array methods" do
      lambda{
       @b.first
       @b.last
       @b[0]
      }.should_not raise_error
    end
    it "should iterate through collection and check dirtyness for #dirty?" do
      @b.first.should_receive(:dirty?).once.and_return(false)
      @b.last.should_receive(:dirty?).once.and_return(false)
      @b.dirty?.should == false
      @b.first.should_receive(:dirty?).once.and_return(true)
      @b.last.should_receive(:dirty?).once.and_return(false)
      @b.dirty?.should == true
    end
    it "should iterate through collection and not save any objects if clean" do
      @b.first.should_receive(:dirty?).once.and_return(false)
      @b.first.should_not_receive(:save)
      @b.last.should_receive(:dirty?).once.and_return(false)
      @b.last.should_not_receive(:save)
      @b.save
    end
    it "should iterate through collection and save dirty objects only" do
      @b.first.should_receive(:dirty?).once.ordered.and_return(true)
      @b.first.should_receive(:save).once.ordered.and_return(true)
      @b.last.should_receive(:dirty?).once.and_return(false)
      @b.last.should_not_receive(:save)
      @b.save
    end
  end
  
  context "class definitions" do
    it "should have a singlet name same as class name" do
      EventBright::BananaBunch.singlet_name.should == 'banana'
      EventBright::BradyBunch.singlet_name.should == 'bob'
    end
    it "should add an s to the singlet name to get the plural" do
      EventBright::BananaBunch.plural_name.should == 'bananas'
      EventBright::BradyBunch.plural_name.should == 'joe'
    end
    it "should know what class it collects" do
      EventBright::BananaBunch.collection_for.should eql EventBright::Banana
      EventBright::BradyBunch.collection_for.should eql EventBright::Brady
    end
    it "should have a getter" do
      EventBright::BananaBunch.getter.should == "user_list_bananas"
      EventBright::BradyBunch.getter.should == :foo_bar_baz
    end
  end

  it "should map an array of values on initialization" do
    @b.first.val.should == 1
    @b.last.val.should == 2
  end
  
  it "should silently reject useless objects (ones without required attributes, empty ones)"  do
    @bb = EventBright::BradyBunch.new(false, [{"bob" => {:foo => 1}}, {"bob" => {}}, {"bob" => {:bar => 3}}])
    @bb.size.should == 1
  end
end