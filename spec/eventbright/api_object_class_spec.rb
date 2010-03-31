share_examples_for "EventBright::ApiObject class methods" do
  it "should have a singlet name same as class name, or set singlet_name" do
    EventBright::Foo.singlet_name.should == 'foo'
    EventBright::Bar.singlet_name.should == 'baz'
  end
  it "should add an s to the singlet name to get the plural, or use set plural" do
    EventBright::Foo.plural_name.should == 'foos'
    EventBright::Bar.plural_name.should == 'bazzes'
  end
  it "should have ignores" do
    EventBright::Foo.ignores.should == []
    EventBright::Foo.ignores :foo, :bar
    EventBright::Foo.ignores :baz
    EventBright::Foo.ignores.should == [:foo, :bar, :baz]
  end
  it "should have requires" do
    EventBright::Foo.requires.should == []
    EventBright::Foo.requires :foo, :bar
    EventBright::Foo.requires :baz
    EventBright::Foo.requires.should == [:foo, :bar, :baz]
  end
  it "should have reformats" do
    EventBright::Foo.reformats.should == []
    EventBright::Foo.reformats :foo, :bar
    EventBright::Foo.reformats :baz
    EventBright::Foo.reformats.should == [:foo, :bar, :baz]
  end
  it "should have renames" do
    EventBright::Foo.renames.should == {}
    EventBright::Foo.renames :foo => :bar, :quux => :wobble
    EventBright::Foo.renames :baz => :qux
    EventBright::Foo.renames.should == {:foo => :bar, :baz => :qux, :quux => :wobble}
  end
  
  it "should have updatable" do
    f = EventBright::Foo.new(false, {})
    f.should_not respond_to(:attr_1)
    f.should_not respond_to(:attr_2)
    f.should_not respond_to(:attr_3)
    f.should_not respond_to(:attr_3=)
    EventBright::Foo.updatable :attr_1, :attr_2
    EventBright::Foo.updatable :attr_3
    f.should respond_to(:attr_1)
    f.should respond_to(:attr_2)
    f.should respond_to(:attr_3)
    f.should respond_to(:attr_3=)
    f.should_receive(:attribute_set).with(:attr_3, :banana, false)
    f.attr_3 = :banana
  end
  it "should have readable" do
    f = EventBright::Foo.new(false, {})
    f.should_not respond_to(:attr_4)
    f.should_not respond_to(:attr_5)
    f.should_not respond_to(:attr_6)
    f.should_not respond_to(:attr_6=)
    EventBright::Foo.readable :attr_4, :attr_5
    EventBright::Foo.readable :attr_6
    f.should respond_to(:attr_4)
    f.should respond_to(:attr_5)
    f.should respond_to(:attr_6)
    f.should respond_to(:attr_6=)
    f.should_receive(:attribute_set).with(:attr_6, :banana, true)
    f.attr_6 = :banana
  end
  it "should have a readable_date" do
    f = EventBright::Foo.new(false, {})
    time = Time.parse("4/1/2010 13:37")
    EventBright::Foo.readable_date :attr_7, :attr_8
    f.attr_7 = f.attr_8 = "4/1/2010 13:37"
    f.attributes.should == {:attr_7 => time, :attr_8 => time}
    f.attr_7.should == EventBright.formatted_time(time)
  end
  it "should have an updatable_date" do
    f = EventBright::Foo.new(false, {})
    time = Time.parse("4/1/2010 13:37")
    EventBright::Foo.updatable_date :attr_9, :attr_0
    f.attr_9 = f.attr_0 = "4/1/2010 13:37"
    f.attributes.should == {:attr_9 => time, :attr_0 => time}
    f.attr_9.should == EventBright.formatted_time(time)
  end
  it "should have a remap method" do
    f = EventBright::Foo.new(false, {})
    f.should_not respond_to(:banana)
    EventBright::Foo.remap :banana => :attr_1
    f.should respond_to(:banana)
    f.should_receive(:attr_1=).once
    f.should_receive(:attr_1).once
    f.banana = :banana
    f.banana
  end
  
  it "should have the #has method" do
    f = EventBright::Foo.new(false, {})
    f.should_not respond_to(:bar)
    f.class.relations.should == {}
    EventBright::Foo.has :bar => EventBright::Bar
    f.should respond_to(:bar)
    f.should respond_to(:bar=)
    f.class.relations.should have(1).relation
    f.class.relations[:bar].should == EventBright::Bar
  end
  
  it "should have the #collection method" do
    f = EventBright::Foo.new(false, {})
    f.should_not respond_to(:baz)
    f.class.collections.should == {}
    EventBright::Foo.collection :baz => EventBright::BananaBunch
    f.should respond_to(:baz)
    f.should respond_to(:baz=)
    f.class.collections.should have(1).relation
    f.class.collections[:baz].should == EventBright::BananaBunch
  end
end