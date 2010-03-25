module EventBright
  class Organizer
    include EventBright::ApiObject

    updatable :name, :description
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
end