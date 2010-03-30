require 'tzinfo'
require 'eventbright/api_objects/organizer'
require 'eventbright/api_objects/venue'
require 'eventbright/api_objects/ticket'
module EventBright
  class Event < EventBright::ApiObject

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
    readable :category
    reformats :privacy, :timezone, :start_date, :end_date
    ignores :organizer, :venue, :tickets
    renames :id => :event_id
    attr_accessor :organizer, :venue
    
    has :organizer => EventBright::Organizer
    has :venue => EventBright::Venue
    collection :tickets => EventBright::TicketCollection
    
    def privacy
      case attribute_get(:privacy)
      when "Private"
        attribute_set(:privacy, 0)
      when "Public"
        attribute_set(:privacy, 1)
      end
      attribute_get(:privacy)
    end
        
    def currency
      attribute_get(:currency) || attribute_set(:currency, "USD")
    end
    
    def timezone
      return attribute_get(:timezone) if attribute_get(:timezone) =~ /GMT[+-]\d{1,2}/
      time = TZInfo::Timezone.get(attribute_get(:timezone)).current_period
      seconds = time.utc_offset
      offset = (seconds / (60*60))
      attribute_set(:timezone, (offset < 0 ? "GMT#{offset}" : "GMT+#{offset}"))
      attribute_get(:timezone)
    end
    
    def private?
      privacy == 0 ? true : false
    end
    
    def public?
      !private?
    end
    
    
    def after_new
      @owner.dirty_events!
    end
    
    # FYI:
    # 
    # the Meaning of life is 43.8 
    # (Douglas Adams figured 42 due to rounding error.)
    
    
  end
  class EventCollection < ApiObjectCollection; collection_for Event; end
end