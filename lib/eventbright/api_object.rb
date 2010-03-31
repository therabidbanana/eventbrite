require 'eventbright/api_object_class_methods'
module EventBright
  class ApiObject
    extend EventBright::ApiObjectClassMethods
    attr_accessor :id, :owner
    attr_accessor :attributes, :relations, :collections
    attr_accessor :dirty, :dirty_relations, :dirty_collections
    
    def initialize(owner = false, hash = {})
      preinit
      @id = hash.delete(:id)
      @owner = owner if owner
      load(hash, true)
      init
    end
    
    def preinit
      @attributes = @relations = @collections = {}
      @dirty = @dirty_relations = @dirty_collections = {}
    end
    
    def clean!
      @dirty = @dirty_relations = @dirty_collections = {}
    end
    
    # Callback after initialization
    def init; end
    
    def attribute_get(key);   @attributes[key];   end
    def relation_get(key);    @relations[key];    end
    def collection_get(key);  
      return @collections[key] unless @collections[key].nil? || collection_dirty?(key)
      klass = self.class.collections[key]
      begin
        response = EventBright.call(klass.getter, nested_hash)
        response = unnest_child_response(response)
        c = klass.new(owner, response[klass.plural_name], self)
      rescue EventBright::Error => e
        if e.type == "Not Found" || e.type == "Discount error"
          c = klass.new(owner, nil, self) 
        else
          raise e
        end
      end
      collection_clean!(key)
      collection_set(key, c, self)
    end
    
    
    def collection_clean!(key); @dirty_collections[key] = false;          end
    def collection_dirty!(key); @dirty_collections[key] = true;           end
    def collection_dirty?(key); @dirty_collections[key] ? true : false;   end
    
    def relation_clean!(key);   @dirty_relations[key]   = false;          end
    def relation_dirty!(key);   @dirty_relations[key]   = true;           end
    def relation_dirty?(key);   @dirty_relations[key]   ? true : false;   end
    
    def attribute_set(key, val, no_dirty = false)
      @dirty[key] = true if(@attributes[key] != val && !no_dirty)
      @attributes[key] = val
      after_attribute_set
    end
    
    def after_attribute_set
    end
    
    def relation_set(key, val, no_dirty = false)
      @dirty_relations[key] = true
      @relations[key] = val
    end
    
    def collection_set(key, val, no_dirty = false)
      @collections[key] = val
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
        load_relations_with_hash(hash, no_dirty)
        load_collections_with_hash(hash, no_dirty)
      end
      clean! if no_dirty
      after_load(hash)
    end
    
    def unnest_child_response(response)
      response["#{self.class.singlet_name}"]
    end
    
    def init_with_hash(hash, no_dirty = false)
      @attributes ||= {}
      hash.each do |k, v| 
        self.__send__("#{k}=", v, no_dirty) unless (self.class.ignores.include?(k) ||
                                                    self.class.ignores.include?(k.to_sym)) ||
                                                    self.class.relations.include?(k) ||
                                                    self.class.relations.include?(k.to_sym) ||
                                                    self.class.collections.include?(k) ||
                                                    self.class.collections.include?(k.to_sym)
      end
    end
    
    def load_relations_with_hash(hash, no_dirty = false)
      self.class.relations.each do |rel, klass|
        relation_set(rel, klass.new(owner, hash.delete(klass.singlet_name)), no_dirty) if hash[klass.singlet_name]
      end
    end
    
    def load_collections_with_hash(hash, no_dirty = false)
      self.class.relations.each do |rel, klass|
        collection_set(rel, klass.new(owner, hash.delete(klass.plural_name)), false, self) if hash[klass.singlet_name]
      end
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
    def api_hash;     {:user => owner};  end
    def update_hash;  {};                 end
    def get_hash;     {};                 end
    def new_hash;     {};                 end
    
    def nested_hash;  {:user => owner, :id => id}; end
    
    
    # Forces a clean load from the remote API. Load can be passed a hash of local
    # values to avoid an API call, but this circumvents it.
    def load!
      load({}, true)
    end
    
    
    # Callback that happens before saving. Allows modification of options
    def before_save(opts = {});   opts;     end
    
    # Save function. Can alter functionality by changing callbacks
    def save(opts = {})
      return false unless dirty?
      opts.merge!(updatable_hash(self.class.requires))
      opts = relations_save(opts)
      opts = before_save(opts)
      call = if loaded?
        c = EventBright.call("#{self.class.singlet_name}_update", prep_api_hash('update', opts))
        after_update
        c
      else
        c = EventBright.call("#{self.class.singlet_name}_new", prep_api_hash('new', opts))
        after_new
        c
      end
      self.id = call["process"]["id"] unless loaded?
      collections_save
      after_save
      clean!
      call
    end
    
    def relations_save(opts)
      self.class.relations.each do |rel, klass|
        relation_get(rel).save if relation_get(rel) && relation_get(rel).dirty?
        opts["#{rel.to_s}_id"] = relation_get(rel).id if relation_dirty?(rel)
        opts.delete(rel)
      end
      opts
    end
    
    def collections_save
      self.class.collections.each do |col, klass|
        collection_get(col).save if collection_get(col)
      end
    end
    
    # After save callback, only called on a new call
    def after_new;    end
    # After save callback, only called on an update call
    def after_update; end
    # After save callback
    def after_save; end
    
    
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
    
    def to_s
      "#<#{self.class.to_s}:#{self.id} @attributes=#{@attributes.inspect}>"
    end
    
    # Defines whether the object has been loaded from a remote source. If not, then
    # we assume it's new when saving.
    def loaded?
      (!@id.nil? || @id == "")
    end
    
    # Something is dirty if it's never been loaded or if the @dirty
    # hash contains something. 
    def dirty?
      @dirty ||= {}
      @dirty.size > 0 || !loaded?
    end
    
  end
end