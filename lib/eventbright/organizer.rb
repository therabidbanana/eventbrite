module EventBright
  class Organizer < EventBright::ApiObject

    updatable :name, :description
    attr_accessor :url
    def initialize(owner = user, hash = {})
      init_with_hash(hash)
      @owner = owner
    end
    
    def save
      opts = {:user => @owner}
      opts.merge!(update_hash)
      if loaded?
        opts.merge! :id => @id
        EventBright.call(:organizer_update, opts)
      else
        @owner.dirty_organizers!
        EventBright.call(:organizer_new, opts)
      end
    end
    
  end
  class OrganizerCollection < ApiObjectCollection; collection_for Organizer; end
end