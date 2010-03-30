module EventBright
  class ApiObject
    attr_accessor :id
    def self.updatable(*args)
      args.each{|symbol|
        module_eval( "def #{symbol}(); attribute_get(:#{symbol});  end")
        module_eval( "def #{symbol}=(val, no_dirty = false); attribute_set(:#{symbol}, val, no_dirty); end")
      }
    end
    
    def self.readable(*args)
      args.each{|symbol|
        
        module_eval( "def #{symbol}(); attribute_get(:#{symbol}); end")
        module_eval( "def #{symbol}=(val, no_dirty = false); attribute_set(:#{symbol}, val, true); end")
      }
    end
    
    def self.updatable_date(*args)
      args.each{|symbol|
        
        module_eval( "def #{symbol}(); EventBright.formatted_time(attribute_get(:#{symbol})); end")
        module_eval( "def #{symbol}=(val, no_dirty = false); attribute_set(:#{symbol}, Time.parse(val), no_dirty); end")
      }
    end
    
    def self.readable_date(*args)
      args.each{|symbol|
        
        module_eval( "def #{symbol}(); EventBright.formatted_time(attribute_get(:#{symbol})); end")
        module_eval( "def #{symbol}=(val, no_dirty = false); attribute_set(:#{symbol}, Time.parse(val), true); end")
      }
    end
    
    def self.remap(args = {})
      args.each{|k,v|
        module_eval( "def #{k}(); #{v};  end")
        module_eval( "def #{k}=(val,no_dirty = false); self.__send__('#{v}=', val, no_dirty); end")
      }
    end
    
    def attribute_get(key)
      @attributes[key]
    end
    
    def attribute_set(key, val, no_dirty = false)
      @dirty ||= {}
      @attributes ||= {}
      @dirty[key] = true if(@attributes[key] != val && !no_dirty)
      eval("@#{key} = val")
      @attributes[key] = val
      after_attribute_set
    end
    
    def after_attribute_set
    end
    
    def id
      @id
    end
    def id=(new_id,*args)
      @id = new_id.to_int
    end
    
    def init_with_hash(hash, ignore = [], no_dirty = false)
      @attributes ||= {}
      hash.each{|k, v| self.__send__("#{k}=", v, no_dirty) unless ignore.include? k }
    end
    
    
    def update_hash(always_dirty = [])
      updates = {}
      @attributes.each do |k, v|
        updates[k] = @attributes[k] if @dirty[k] || always_dirty.include?(k)
      end
      updates.merge! :id => @id if @id
      updates
    end
    
    def inspect
      "#<#{self.class.to_s}:#{self.id} @attributes=#{@attributes.inspect}>"
    end
    
    
    # Defines whether the object has been loaded from a remote source. If not, then
    # we assume it's new when saving.
    def loaded?
      (!@id.nil? || @id == "")
    end
    
    def dirty?
      @dirty.nil? || @dirty.size > 0 || !loaded?
    end
  end
  
  class ApiObjectCollection
    def self.collection_for(type = false)
      @collection_for = type if type
      @collection_for 
    end
    
    def self.singlet_name(name = false)
      @singlet_name = name if name
      @singlet_name || @collection_for.to_s.gsub('EventBright::', '').downcase
    end
    
    def self.plural_name(name = false)
      @plural_name = name if name
      @plural_name || "#{self.singlet_name}s"
    end
    
    def initialize(owner = false, hash_array = [], reject_if_empty = false)
      @owner = owner
      arr = hash_array.map{|v| v[self.class.singlet_name]}
      arr = arr.reject{|v| v[reject_if_empty] == ""} if reject_if_empty
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
    end
    
    def method_missing(meth, *args, &block)
      @array.__send__(meth, *args, &block)
    end
  end
  
end