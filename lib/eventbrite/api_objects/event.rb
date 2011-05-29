require 'eventbrite/api_objects/organizer'
require 'eventbrite/api_objects/venue'
require 'eventbrite/api_objects/ticket'
require 'eventbrite/api_objects/organizer'
require 'eventbrite/api_objects/discount'
require 'eventbrite/api_objects/attendee'
module Eventbrite

  # The Event class is the main point of interaction for most Eventbrite api
  # calls. Most objects have to be directly related to an Event.
  #
  # Events must have a Venue and an Organizer.
  #
  # Events have collections of Attendees, Tickets,  and Discounts
  class Event < Eventbrite::ApiObject

    updatable :title, :description, :tags, :timezone
    updatable_date :start_date, :end_date
    updatable :capacity, :url
    updatable :privacy, :password, :status
    updatable :created, :modified, :logo, :logo_ssl
    updatable :text_color, :link_color, :title_text_color, :background_color
    updatable :box_background_color, :box_text_color, :box_border_color
    updatable :box_header_background_color, :box_header_text_color 
    updatable :currency
    updatable :venue_id, :organizer_id
    readable :category, :num_attendee_rows
    reformats :privacy, :timezone, :start_date, :end_date
    
    requires :title
    ignores :organizer, :venue, :tickets
    renames :id => :event_id
    attr_accessor :organizer, :venue
    
    has :organizer => Eventbrite::Organizer
    has :venue => Eventbrite::Venue
    collection :tickets => Eventbrite::TicketCollection
    collection :attendees => Eventbrite::AttendeeCollection
    collection :discounts => Eventbrite::DiscountCollection
    
    # Returns privacy status of event
    def privacy
      case attribute_get(:privacy)
      when "Private"
        attribute_set(:privacy, 0)
      when "Public"
        attribute_set(:privacy, 1)
      end
      attribute_get(:privacy)
    end
    
    # Returns currency, setting to default of USD.
    def currency
      attribute_get(:currency) || attribute_set(:currency, "USD")
    end
    
    # Returns timezone, reformatting to GMT offset if necessary.
    def timezone
      return attribute_get(:timezone) if attribute_get(:timezone) =~ /GMT[+-]\d{1,2}/
      time = TZInfo::Timezone.get(attribute_get(:timezone)).current_period
      seconds = time.utc_offset
      offset = (seconds / (60*60))
      attribute_set(:timezone, (offset < 0 ? "GMT#{offset}" : "GMT+#{offset}"))
      attribute_get(:timezone)
    end
    
    # Returns true if event is private
    def private?
      privacy == 0 ? true : false
    end
    
    # Returns true if event is not private
    def public?
      !private?
    end
    
    # @private
    # Handle differences in api - occasionally response is double
    # wrapped in the XML.
    def unnest_child_response(response)
      response.has_key?('event') ? response['event'] : response
    end
    
    # @private
    # Mark the user's event collection as dirty
    def after_new
      @owner.dirty_events!
    end
    
    # @private
    # When requesting collections, request as many as possible.
    def nested_hash
      {:id => id, :count => 99999, :user => owner} # It's over 9000!
    end
    
  end

  # A collection of events.
  class EventCollection < ApiObjectCollection; collection_for Event; end
end
