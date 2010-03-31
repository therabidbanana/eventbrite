module EventBright
  module ApiObjectClassMethods
    def singlet_name(name = false)
      @singlet_name = name if name
      @singlet_name || self.to_s.gsub('EventBright::', '').downcase
    end
  
    def plural_name(name = false)
      @plural_name = name if name
      @plural_name || "#{self.singlet_name}s"
    end
  
    def ignores(*args)
      @ignores ||= []
      @ignores.concat(args) unless args.empty?
      @ignores
    end
    
    def requires(*args)
      @requires ||= []
      @requires.concat(args) unless args.empty?
      @requires
    end
    
    # Columns to reformat when sending outgoing data
    # (Reformatting is assumed to be done by calling the method with the
    # same name as the attribute, so to reformat foo, use def foo... with 
    # an attribute_get inside)
    def reformats(*args)
      @reformats ||= []
      @reformats.concat(args) unless args.empty?
      @reformats
    end
    
    # Columns to rename when sending outgoing data
    def renames(attrs = false)
      @renames ||= {}
      @renames.merge!(attrs) if attrs
      @renames
    end
  
    def updatable(*args)
      args.each{|symbol|
        module_eval( "def #{symbol}(); attribute_get(:#{symbol});  end")
        module_eval( "def #{symbol}=(val, no_dirty = false); attribute_set(:#{symbol}, val, no_dirty); end")
      }
    end
  
    def readable(*args)
      args.each{|symbol|
      
        module_eval( "def #{symbol}(); attribute_get(:#{symbol}); end")
        module_eval( "def #{symbol}=(val, no_dirty = false); attribute_set(:#{symbol}, val, true); end")
      }
    end
  
    def updatable_date(*args)
      args.each{|symbol|
      
        module_eval( "def #{symbol}(); EventBright.formatted_time(attribute_get(:#{symbol})); end")
        module_eval( "def #{symbol}=(val, no_dirty = false); attribute_set(:#{symbol}, Time.parse(val), no_dirty); end")
      }
    end
  
    def readable_date(*args)
      args.each{|symbol|
      
        module_eval( "def #{symbol}(); EventBright.formatted_time(attribute_get(:#{symbol})); end")
        module_eval( "def #{symbol}=(val, no_dirty = false); attribute_set(:#{symbol}, Time.parse(val), true); end")
      }
    end
    
    # Columns that are the same as other columns. This is mainly useful
    # for incoming data with inconsistent naming. Args are passed as a hash,
    # where the key is the new method name, and the value is the target method name
    # you are mapping the new one onto. Note that this  means there is only the original
    # one stored on the object. Also note this is different from the 
    # renames list, which is exclusively for outgoing hashes sent to the API.
    def remap(args = {})
      args.each{|k,v|
        module_eval( "def #{k}(); #{v};  end")
        module_eval( "def #{k}=(val,no_dirty = false); self.__send__('#{v}=', val, no_dirty); end")
      }
    end
    
    # Defines a has 1 relation
    def has(args = {})
      @class_relations ||= {}
      args.each{|symbol, klass|
        module_eval( "def #{symbol}(); relation_get(:#{symbol});  end")
        module_eval( "def dirty_#{symbol}!(); relation_dirty!(:#{symbol});  end")
        module_eval( "def dirty_#{symbol}?(); relation_dirty?(:#{symbol});  end")
        module_eval( "def #{symbol}=(val, no_dirty = false); relation_set(:#{symbol}, val, no_dirty); end")
        @class_relations[symbol] = klass
      }
    end
    def relations
      @class_relations || {}
    end
    
    # Defines a has may relation
    def collection(args = {})
      @class_collections ||= {}
      args.each{|symbol, klass|
        module_eval( "def #{symbol}(); collection_get(:#{symbol});  end")
        module_eval( "def dirty_#{symbol}!(); collection_dirty!(:#{symbol});  end")
        module_eval( "def dirty_#{symbol}?(); collection_dirty?(:#{symbol});  end")
        module_eval( "def #{symbol}=(val, no_dirty = false); collection_set(:#{symbol}, val, no_dirty); end")
        @class_collections[symbol] = klass
      }
    end
    def collections
      @class_collections || {}
    end

  end
end