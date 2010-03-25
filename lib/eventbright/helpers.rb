module EventBright
  module ApiObject
    def self.included(mod)
      mod.extend ApiObjectClass
    end
    def id
      @id
    end
    def id=(new_id)
      @id = new_id.to_int
    end
    
    def init_with_hash(hash, ignore = [])
      hash.each{|k, v| self.__send__("#{k}=", v) unless ignore.include? k }
    end
    
    
    def update_hash
      updates = {}
      @attributes.each do |k, v|
        updates[k] = @attributes[k] if @dirty[k]
      end
      updates.merge! :id => @id if @id
      updates
    end
    
    
    # Defines whether the object has been loaded from a remote source. If not, then
    # we assume it's new when saving.
    def loaded?
      (!@id.nil? || @id = "")
    end
  end
  module ApiObjectClass
    attr_accessor :id
    def updatable(*args)
      args.each{|symbol|
        module_eval( "def #{symbol}(); @#{symbol};  end")
        module_eval( "def #{symbol}=(val); @dirty ||= {}; @attributes ||= {}; @dirty[:#{symbol}] = true if(loaded? && @#{symbol} != val); @#{symbol} = val; @attributes[:#{symbol}] = val; end")
      }
    end
  end
end