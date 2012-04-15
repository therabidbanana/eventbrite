require 'eventbrite/api_object_class_methods'
require 'eventbrite/api_object_relationships'
module Eventbrite
  # @private
  # Class for generalizing API interactions
  class ApiObject
    extend Eventbrite::ApiObjectClassMethods
    include Eventbrite::ApiObjectRelationships
    
    attr_accessor :id, :owner
    # @private
    # Individual attribute tracking
    attr_accessor :attributes, :relations, :collections
    # @private
    # Dirty tracking
    attr_accessor :dirty, :dirty_relations, :dirty_collections
    
    def initialize(owner = false, hash = {})
      preinit
      @owner = owner if owner
      unless hash.empty?
        @id = hash.delete(:id)
        load(hash, true)
        init
      end
    end
    
    # @private
    # Initializes all attributes and dirtry tracking
    def preinit
      @attributes = @relations = @collections = {}
      @dirty = @dirty_relations = @dirty_collections = {}
    end
    
    # @private
    # Marks everything as clean.
    def clean!
      @dirty = @dirty_relations = @dirty_collections = {}
    end
    
    # @private
    # Callback after initialization
    def init; end
    
    # @private
    # Standard getter for attributes array
    def attribute_get(key);   @attributes[key];   end
   
    # @private
    # Standard setter for attributes, also tracking dirtiness
    def attribute_set(key, val, no_dirty = false)
      @dirty[key] = true if(@attributes[key] != val && !no_dirty)
      @attributes[key] = val
      after_attribute_set
    end
    
    # @private
    # Callback for when attributes are set.
    def after_attribute_set
    end
    
    # @private
    # Convert id to integer
    def id=(new_id,*args)
      @id = new_id.to_i
    end
    
    # Loads attributes and relations from a hash, 
    # or makes an API call to retrieve necessary data if load hash is empty
    #
    # The no_dirty attribute allows you to force a dirty tracking to recognize
    # the object as clean.
    def load(hash = {}, no_dirty = false)
      if hash.nil? || hash.size == 0
      
        response = Eventbrite.call("#{self.class.singlet_name}_get", prep_api_hash('get'))
        hash = response["#{self.class.singlet_name}"]
        warn hash.inspect
      end
      unless hash.nil? || hash.size == 0
        init_with_hash(hash, no_dirty)
        load_relations_with_hash(hash, no_dirty)
        load_collections_with_hash(hash, no_dirty)
      end
      clean! if no_dirty
      after_load(hash)
    end
    
    # @private
    # Loads all attributes from hash unless set to ignore.
    def init_with_hash(hash, no_dirty = false)
      @attributes ||= {}
      hash.each do |k, v| 
        self.__send__("#{k}=", v, no_dirty) unless (self.class.ignores.include?(k) ||
                                                    self.class.ignores.include?(k.to_sym)) ||
                                                    self.class.relations.include?(k) ||
                                                    self.class.relations.include?(k.to_sym) ||
                                                    self.class.collections.include?(k) ||
                                                    self.class.collections.include?(k.to_sym) ||
                                                    !self.respond_to?(k)
      end
    end
    
    # @private
    # A callback for after loads
    def after_load(hash = {})
      hash
    end
    
    # @private
    # A callback for methods to clean up the hash a bit
    # allowing subclasses to insert the user if necessary
    def prep_api_hash(method = 'get', hash = {})
      hash = hash.merge api_hash
      hash = hash.merge get_hash if method == 'get'
      hash = hash.merge new_hash if method == 'new'
      hash = hash.merge update_hash if method == 'update'
      hash
    end
    
    # @private
    # Callbacks for individual hash changes
    # These are added to the updatable_hash, if appropriate
    # These are called by prep_api_hash
    def api_hash;     {:user => owner};  end
    # @private
    def update_hash;  {:id => id};       end
    # @private
    def get_hash;     {:id => id};       end
    # @private
    def new_hash;     {};                end
    
    # @private
    def nested_hash;  {:user => owner, :id => id}; end
    
    
    # Forces a clean load from the remote API. #load can be passed a hash of local
    # values to avoid an API call, but this circumvents it.
    def load!
      load({}, true)
    end
    
    # @private
    # Callback that happens before saving. Allows modification of options
    def before_save(opts = {});   opts;     end
    
    # Save function. Individual objects can alter functionality by changing callbacks
    def save(opts = {})
      return false unless dirty?
      opts.merge!(updatable_hash(self.class.requires))
      opts = relations_save(opts)
      opts = before_save(opts)
      call = if loaded?
        c = Eventbrite.call("#{self.class.singlet_name}_update", prep_api_hash('update', opts))
        after_update
        c
      else
        c = Eventbrite.call("#{self.class.singlet_name}_new", prep_api_hash('new', opts))
        after_new
        c
      end
      self.id = call["process"]["id"] unless loaded?
      collections_save
      after_save
      clean!
      call
    end
    
    # @private
    # After save callback, only called on a new call
    def after_new;    end
    # @private
    # After save callback, only called on an update call
    def after_update; end
    # @private
    # After save callback
    def after_save; end
    
    # @private
    # Creates a hash of attributes for an update
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
    
    # @private
    def inspect
      "#<#{self.class.to_s}:#{self.id} @attributes=#{@attributes.inspect}>"
    end
    
    # Returns a simple string representing the class and its attributes
    def to_s
      "#<#{self.class.to_s}:#{self.id} @attributes=#{@attributes.inspect}>"
    end
    
    
    # Defines whether the object has been loaded from a remote source. If not, then
    # we assume it's new when saving.
    def loaded?
      (!@id.nil? || @id == "")
    end
    
    # Something is dirty if it's never been loaded or if the @dirty
    # hash contains something (which happens when an attribute is changed)
    def dirty?
      @dirty ||= {}
      @dirty.size > 0 || !loaded?
    end
    
  end
end
