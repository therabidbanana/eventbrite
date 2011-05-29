share_examples_for "Eventbrite::ApiObject class methods" do
  it "should have a singlet name same as class name, or set singlet_name" do
    Eventbrite::Foo.singlet_name.should == 'foo'
    Eventbrite::Bar.singlet_name.should == 'baz'
  end
  it "should add an s to the singlet name to get the plural, or use set plural" do
    Eventbrite::Foo.plural_name.should == 'foos'
    Eventbrite::Bar.plural_name.should == 'bazzes'
  end
  it "should have ignores" do
    Eventbrite::Foo.ignores.should == []
    Eventbrite::Foo.ignores :foo, :bar
    Eventbrite::Foo.ignores :baz
    Eventbrite::Foo.ignores.should == [:foo, :bar, :baz]
  end
  it "should have requires" do
    Eventbrite::Foo.requires.should == []
    Eventbrite::Foo.requires :foo, :bar
    Eventbrite::Foo.requires :baz
    Eventbrite::Foo.requires.should == [:foo, :bar, :baz]
  end
  it "should have reformats" do
    Eventbrite::Foo.reformats.should == []
    Eventbrite::Foo.reformats :foo, :bar
    Eventbrite::Foo.reformats :baz
    Eventbrite::Foo.reformats.should == [:foo, :bar, :baz]
  end
  it "should have renames" do
    Eventbrite::Foo.renames.should == {}
    Eventbrite::Foo.renames :foo => :bar, :quux => :wobble
    Eventbrite::Foo.renames :baz => :qux
    Eventbrite::Foo.renames.should == {:foo => :bar, :baz => :qux, :quux => :wobble}
  end
  
  it "should have updatable" do
    f = Eventbrite::Foo.new(false, {})
    f.should_not respond_to(:attr_1)
    f.should_not respond_to(:attr_2)
    f.should_not respond_to(:attr_3)
    f.should_not respond_to(:attr_3=)
    Eventbrite::Foo.updatable :attr_1, :attr_2
    Eventbrite::Foo.updatable :attr_3
    f.should respond_to(:attr_1)
    f.should respond_to(:attr_2)
    f.should respond_to(:attr_3)
    f.should respond_to(:attr_3=)
    f.should_receive(:attribute_set).with(:attr_3, :banana, false)
    f.attr_3 = :banana
  end
  it "should have readable" do
    f = Eventbrite::Foo.new(false, {})
    f.should_not respond_to(:attr_4)
    f.should_not respond_to(:attr_5)
    f.should_not respond_to(:attr_6)
    f.should_not respond_to(:attr_6=)
    Eventbrite::Foo.readable :attr_4, :attr_5
    Eventbrite::Foo.readable :attr_6
    f.should respond_to(:attr_4)
    f.should respond_to(:attr_5)
    f.should respond_to(:attr_6)
    f.should respond_to(:attr_6=)
    f.should_receive(:attribute_set).with(:attr_6, :banana, true)
    f.attr_6 = :banana
  end
  it "should have a readable_date" do
    f = Eventbrite::Foo.new(false, {})
    time = Time.parse("4/1/2010 13:37")
    Eventbrite::Foo.readable_date :attr_7, :attr_8
    f.attr_7 = f.attr_8 = "4/1/2010 13:37"
    f.attributes.should == {:attr_7 => time, :attr_8 => time}
    f.attr_7.should == Eventbrite.formatted_time(time)
  end
  it "should have an updatable_date" do
    f = Eventbrite::Foo.new(false, {})
    time = Time.parse("4/1/2010 13:37")
    Eventbrite::Foo.updatable_date :attr_9, :attr_0
    f.attr_9 = f.attr_0 = "4/1/2010 13:37"
    f.attributes.should == {:attr_9 => time, :attr_0 => time}
    f.attr_9.should == Eventbrite.formatted_time(time)
  end
  it "should have a remap method" do
    f = Eventbrite::Foo.new(false, {})
    f.should_not respond_to(:banana)
    Eventbrite::Foo.remap :banana => :attr_1
    f.should respond_to(:banana)
    f.should_receive(:attr_1=).once
    f.should_receive(:attr_1).once
    f.banana = :banana
    f.banana
  end
  
  it "should have the #has method" do
    f = Eventbrite::Foo.new(false, {})
    f.should_not respond_to(:bar)
    f.class.relations.should == {}
    Eventbrite::Foo.has :bar => Eventbrite::Bar
    f.should respond_to(:bar)
    f.should respond_to(:bar=)
    f.class.relations.should have(1).relation
    f.class.relations[:bar].should == Eventbrite::Bar
  end
  
  it "should have the #collection method" do
    f = Eventbrite::Foo.new(false, {})
    f.should_not respond_to(:baz)
    f.class.collections.should == {}
    Eventbrite::Foo.collection :baz => Eventbrite::BananaBunch
    f.should respond_to(:baz)
    f.should respond_to(:baz=)
    f.class.collections.should have(1).relation
    f.class.collections[:baz].should == Eventbrite::BananaBunch
  end
end
