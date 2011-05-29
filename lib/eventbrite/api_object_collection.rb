module Eventbrite
  # @private
  # An API Object collection acts mostly as an array, but with dirty tracking.
  class ApiObjectCollection
    
    def initialize(owner = false, hash_array = [], parent = false)
      @owner = owner
      hash_array = [] if hash_array.nil?
      arr = hash_array.map{|v| v[self.class.singlet_name]}.reject{|v| v.empty? }
      @array = arr.map{|v| self.class.collection_for.new(owner, v)}
      @array = @array.reject{|v| v.__send__(self.class.collection_for.requires.first).nil? || v.__send__(self.class.collection_for.requires.first) == ""} unless self.class.collection_for.requires.empty?
    end
    
    # @private
    def inspect
      "#{@array.inspect}"
    end
    
    # Returns an list of objects contained in this collection.
    def to_s
      "#{@array.inspect}"
    end
    
    # Saves all objects that are dirty within a collection
    def save
      @array.each do |a|
        a.save if a.dirty?
      end
    end
    
    # Returns true if any object in collection is dirty
    def dirty?
      is_dirty = false
      @array.each do |a|
        is_dirty = true if a.dirty?
      end
      is_dirty
    end
    
    # All undefined methods are passed through to the standard Ruby Array of items
    # (so you can call #map or #size)
    def method_missing(meth, *args, &block)
      @array.__send__(meth, *args, &block)
    end
    
    # @private
    # Declares which class this is a collection for
    def self.collection_for(type = false)
      @collection_for = type if type
      @collection_for 
    end

    # @private
    # Declares the singular name for this object
    def self.singlet_name(name = false)
      @singlet_name = name if name
      @singlet_name || @collection_for.singlet_name
    end

    # @private
    # Declares the plural name for this collection, defaulting to singular + s
    def self.plural_name(name = false)
      @plural_name = name if name
      @plural_name || @collection_for.plural_name || "#{self.singlet_name}s"
    end

    # @private
    # Defines the API call to get the collection, defaulting to
    # user_list_#{plural_name}
    def self.getter(name = false)
      @getter = name if name
      @getter || "user_list_#{self.plural_name}"
    end
  end
end
