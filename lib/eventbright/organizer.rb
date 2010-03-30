module EventBright
  class Organizer < EventBright::ApiObject

    updatable :name, :description
    readable :url
    def initialize(owner = user, hash = {})
      @id = hash.delete(:id)
      init_with_hash(hash, true)
      @owner = owner
    end
    
    def after_new
      @owner.dirty_organizers!
    end
    
  end
  class OrganizerCollection < ApiObjectCollection; collection_for Organizer; end
end