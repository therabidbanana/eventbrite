module Eventbrite
  module ApiObjectRelationships
    def relation_get(key);    @relations[key];    end
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


    def collection_clean!(key); @dirty_collections[key] = false;          end
    def collection_dirty!(key); @dirty_collections[key] = true;           end
    def collection_dirty?(key); @dirty_collections[key] ? true : false;   end

    def relation_clean!(key);   @dirty_relations[key]   = false;          end
    def relation_dirty!(key);   @dirty_relations[key]   = true;           end
    def relation_dirty?(key);   @dirty_relations[key]   ? true : false;   end
    

    def relation_set(key, val, no_dirty = false)
      @dirty_relations[key] = true
      @relations[key] = val
    end

    def collection_set(key, val, no_dirty = false)
      @collections[key] = val
    end
    
    def unnest_child_response(response)
      response["#{self.class.singlet_name}"]
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
  end
end
