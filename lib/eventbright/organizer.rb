module EventBright
  class Organizer < EventBright::ApiObject

    updatable :name, :description
    readable :url
    def initialize(owner = user, hash = {})
      @id = hash.delete(:id)
      init_with_hash(hash)
      @owner = owner
    end
    
    def save
      opts = {:user => @owner}
      opts.merge!(update_hash)
      call = if loaded?
        opts.merge! :id => @id
        EventBright.call(:organizer_update, opts)
      else
        @owner.dirty_organizers!
        EventBright.call(:organizer_new, opts)
      end
      self.id = call["process"]["id"] unless loaded?
      @dirty = {}
      call
    end
    
  end
  class OrganizerCollection < ApiObjectCollection; collection_for Organizer; end
end