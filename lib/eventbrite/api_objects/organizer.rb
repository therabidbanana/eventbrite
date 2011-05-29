module Eventbrite
  class Event < Eventbrite::ApiObject; end
  
  # Represents a collection of {Eventbrite::Event events} the
  # {Eventbrite::Organizer organizer} owns.
  class OrganizerEventCollection < ApiObjectCollection
    collection_for Event
    getter :organizer_list_events
  end
  
  # An organizer is the person organizing an {Eventbrite::Event event} (which is not necessarily
  # the same as the {Eventbrite::User user}). Organizers are required for events.
  class Organizer < Eventbrite::ApiObject

    updatable :name, :description
    readable :url
    
    requires :name
    collection :events => Eventbrite::OrganizerEventCollection

    # @private
    # Upon creating an organizer, the user is dirty.
    def after_new
      @owner.dirty_organizers!
    end
    
    # @private
    # Organizers aren't double nested
    def unnest_child_response(response)
      response
    end
  end
  
  # Represents a list of organizers
  class OrganizerCollection < ApiObjectCollection; collection_for Organizer; end
end
