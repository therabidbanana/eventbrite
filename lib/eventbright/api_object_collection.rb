module EventBright
  class ApiObjectCollection
    def self.collection_for(type = false)
      @collection_for = type if type
      @collection_for 
    end
    
    def self.singlet_name(name = false)
      @singlet_name = name if name
      @singlet_name || @collection_for.singlet_name
    end
    
    def self.plural_name(name = false)
      @plural_name = name if name
      @plural_name || @collection_for.plural_name || "#{self.singlet_name}s"
    end
    
    
    def self.getter(name = false)
      @getter = name if name
      @getter || "user_list_#{self.plural_name}"
    end
    
    def initialize(owner = false, hash_array = [], parent = false)
      @owner = owner
      arr = hash_array.map{|v| v[self.class.singlet_name]}
      # arr = arr.reject{|v| v[reject_if_empty] == ""} if reject_if_empty
      @array = arr.map{|v| self.class.collection_for.new(owner, v)}
    end
    
    def inspect
      "#{@array.inspect}"
    end
    
    def save
      @array.each do |a|
        a.save if a.dirty?
      end
    end
    
    def dirty?
      is_dirty = false
      @array.each do |a|
        is_dirty = true if a.dirty?
      end
      is_dirty
    end
    
    def method_missing(meth, *args, &block)
      @array.__send__(meth, *args, &block)
    end
  end
  
end