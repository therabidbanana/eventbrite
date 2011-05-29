module Eventbrite
  class Event < Eventbrite::ApiObject; end
  class OrganizerEventCollection < ApiObjectCollection
    collection_for Event
    getter :organizer_list_events
  end
  
  class Organizer < Eventbrite::ApiObject

    updatable :name, :description
    readable :url
    
    requires :name
    collection :events => Eventbrite::OrganizerEventCollection
    def after_new
      @owner.dirty_organizers!
    end
    
    
    def unnest_child_response(response)
      response
    end
  end
  
  class OrganizerCollection < ApiObjectCollection; collection_for Organizer; end
end
