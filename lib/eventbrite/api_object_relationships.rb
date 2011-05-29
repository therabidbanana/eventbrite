module Eventbrite
  # @private
  module ApiObjectRelationships
    # @private
    def relation_get(key);    @relations[key];    end
    # @private
    # Gets a collection for this relationship
    def collection_get(key);  
      return @collections[key] unless @collections[key].nil? || collection_dirty?(key)
      klass = self.class.collections[key]
      begin
        response = Eventbrite.call(klass.getter, nested_hash)
        response = unnest_child_response(response)
        c = klass.new(owner, response[klass.plural_name], self)
      rescue Eventbrite::Error => e
        if e.type == "Not Found" || e.type == "Discount error" || e.type == "Order error"
          c = klass.new(owner, nil, self) 
        else
          raise e
        end
      end
      collection_clean!(key)
      collection_set(key, c, self)
    end

    # @private
    # Force clean for relationship
    def collection_clean!(key); @dirty_collections[key] = false;          end
    # @private
    # Force collection to be dirty
    def collection_dirty!(key); @dirty_collections[key] = true;           end
    # @private
    # Returns true if collection is dirty
    def collection_dirty?(key); @dirty_collections[key] ? true : false;   end

    # @private
    # Force relation to be clean
    def relation_clean!(key);   @dirty_relations[key]   = false;          end
    # @private
    # Force relation to be dirty
    def relation_dirty!(key);   @dirty_relations[key]   = true;           end
    # @private
    # Returns true if relation is dirty
    def relation_dirty?(key);   @dirty_relations[key]   ? true : false;   end
    
    # @private
    # Set a relationship to a value
    def relation_set(key, val, no_dirty = false)
      @dirty_relations[key] = true
      @relations[key] = val
    end

    # @private 
    # Set a collection to a value
    def collection_set(key, val, no_dirty = false)
      @collections[key] = val
    end
    
    # @private
    # Unwraps XML response
    def unnest_child_response(response)
      response["#{self.class.singlet_name}"]
    end
    
    # @private
    # Load any existing relationships from a hash
    def load_relations_with_hash(hash, no_dirty = false)
      self.class.relations.each do |rel, klass|
        relation_set(rel, klass.new(owner, hash.delete(klass.singlet_name)), no_dirty) if hash[klass.singlet_name]
      end
    end

    # @private
    # Load any existing collections from a hash
    def load_collections_with_hash(hash, no_dirty = false)
      self.class.relations.each do |rel, klass|
        collection_set(rel, klass.new(owner, hash.delete(klass.plural_name)), false, self) if hash[klass.singlet_name]
      end
    end
    
    # @private
    # Saves all relationships (auto called by save)
    def relations_save(opts)
      self.class.relations.each do |rel, klass|
        relation_get(rel).save if relation_get(rel) && relation_get(rel).dirty?
        opts["#{rel.to_s}_id"] = relation_get(rel).id if relation_dirty?(rel)
        opts.delete(rel)
      end
      opts
    end

    # @private
    # Saves all collections if dirty
    def collections_save
      self.class.collections.each do |col, klass|
        collection_get(col).save if collection_get(col)
      end
    end
  end
end
