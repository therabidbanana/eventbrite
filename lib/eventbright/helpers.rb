module EventBright
  class ApiObject
    attr_accessor :id
    class << self
      def singlet_name(name = false)
        @singlet_name = name if name
        @singlet_name || self.to_s.gsub('EventBright::', '').downcase
      end
    
      def plural_name(name = false)
        @plural_name || "#{self.singlet_name}s"
      end
    
      def ignores(*args)
        @ignores = args unless args.empty?
        @ignores || []
      end
      
      def requires(*args)
        @requires = args unless args.empty?
        @requires || []
      end
      
      
      def reformats(*args)
        @reformats = args unless args.empty?
        @reformats || []
      end
      
      
      def renames(attrs = false)
        @reformats = attrs if attrs
        @reformats || {}
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
    
      def remap(args = {})
        args.each{|k,v|
          module_eval( "def #{k}(); #{v};  end")
          module_eval( "def #{k}=(val,no_dirty = false); self.__send__('#{v}=', val, no_dirty); end")
        }
      end
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
    
    def load(hash = {}, no_dirty = false)
      if hash.nil? || hash.size == 0
        response = EventBright.call("#{self.class.singlet_name}_get", prep_api_hash('get'))
        hash = response["#{self.class.singlet_name}"]
      end
      unless hash.nil? || hash.size == 0
        init_with_hash(hash, no_dirty)
      end
      after_load(hash)
    end
    
    # A callback for after loads
    def after_load(hash = {})
      hash
    end
    
    # A callback for methods to clean up the hash a bit
    # allowing subclasses to insert the user if necessary
    def prep_api_hash(method = 'get', hash = {})
      hash = hash.merge api_hash
      hash = hash.merge get_hash if method == 'get'
      hash = hash.merge new_hash if method == 'new'
      hash = hash.merge update_hash if method == 'update'
      hash
    end
    
    # Callbacks for individual hash changes
    # These are added to the updatable_hash, if appropriate
    # These are called by prep_api_hash
    def api_hash;     {:user => @owner};  end
    def update_hash;  {};                 end
    def get_hash;     {};                 end
    def new_hash;     {};                 end
    
    # Forces a clean load from the remote API
    def load!
      load({}, true)
    end
    
    
    # Callback that happens before saving. Allows modification of options
    def before_save(opts = {})
      opts
    end
    
    # Save function. Can alter functionality by changing callbacks
    def save(opts = {})
      return false unless dirty?
      opts.merge!(updatable_hash(self.class.requires))
      opts = before_save(opts)
      call = if loaded?
        EventBright.call("#{self.class.singlet_name}_update", prep_api_hash('update', opts))
        after_update
      else
        EventBright.call("#{self.class.singlet_name}_new", prep_api_hash('new', opts))
        after_new
      end
      self.id = call["process"]["id"] unless loaded?
      @dirty = {}
      call
    end
    
    # After save callback, only called on a new call
    def after_new
    end
    
    # After save callback, only called on an update call
    def after_update
    end
    
    def owner
      @owner
    end
    
    def init_with_hash(hash, no_dirty = false)
      @attributes ||= {}
      hash.each{|k, v| self.__send__("#{k}=", v, no_dirty) unless (self.class.ignores.include?(k) || self.class.ignores.include?(k.to_sym)) }
    end
    
    def updatable_hash(always_dirty = [])
      updates = {}
      @attributes.each do |k, v|
        updates[k] = @attributes[k] if @dirty[k] || always_dirty.include?(k)
      end
      updates.merge! :id => @id if @id
      self.class.reformats.each do |k|
        updates[k] = self.__send__(k) if updates[k]
      end
      self.class.renames.each do |k,v|
        updates[v] = updates.delete(k) if updates[k]
      end
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
      @dirty ||= {}
      @dirty.size > 0 || !loaded?
    end
    
    def attributes
      @attributes
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