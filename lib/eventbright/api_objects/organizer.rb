module EventBright
  class Organizer < EventBright::ApiObject

    updatable :name, :description
    readable :url
    
    def after_new
      @owner.dirty_organizers!
    end
    
  end
  class OrganizerCollection < ApiObjectCollection; collection_for Organizer; end
end