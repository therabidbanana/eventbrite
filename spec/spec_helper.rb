$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'eventbright'
require 'eventbright_api_faker'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end

module EventBright
  class Banana < ApiObject; readable :val; end
  class BananaBunch < ApiObjectCollection
    collection_for Banana
  end
  class Brady < ApiObject; readable :foo, :bar; requires :foo; end
  class BradyBunch < ApiObjectCollection
    collection_for Brady
    singlet_name "bob"
    plural_name "joe"
    getter :foo_bar_baz
  end
  class Foo < ApiObject
  end
  class Bar < ApiObject
    singlet_name "baz"
    plural_name "bazzes"
    readable :foo
    updatable :bar, :baz
    has :banana => EventBright::Banana
    collection :bananas => EventBright::BananaBunch
  end
end