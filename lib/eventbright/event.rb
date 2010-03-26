require 'tzinfo'
module EventBright
  class Event < EventBright::ApiObject

    updatable :title, :description, :tags
    updatable :start_date, :end_date, :timezone
    updatable :capacity, :url
    updatable :privacy, :password, :status
    updatable :created, :modified, :logo, :logo_ssl
    updatable :text_color, :link_color, :title_text_color, :background_color
    updatable :box_background_color, :box_text_color, :box_border_color
    updatable :box_header_background_color, :box_header_text_color 
    updatable :currency
    updatable :venue_id, :organizer_id
    attr_accessor :category
    attr_accessor :organizer, :venue
    def initialize(owner = user, hash = {})
      @organizer = Organizer.new(owner, hash.delete('organizer')) if hash['organizer']
      @venue = Venue.new(owner, hash.delete('venue')) if hash['venue']
      tickets = hash.delete('tickets') if hash['tickets']
      init_with_hash(hash)
      @owner = owner
    end
    
    def privacy
      case @privacy
      when "Private"
        @privacy = 0
      when "Public"
        @privacy = 1
      end
      @privacy
    end
    
    def timezone
      return @timezone if @timezone =~ /GMT[+-]\d{1,2}/
      time = TZInfo::Timezone.get(@timezone).current_period
      seconds = time.utc_offset
      offset = (seconds / (60*60))
      @timezone = (offset < 0 ? "GMT#{offset}" : "GMT+#{offset}")
    end
    
    def private?
      privacy == 0 ? true : false
    end
    
    def public?
      !private?
    end
    
    def load(hash = {})
      if hash.empty?
        response = EventBright.call(:event_get, {:user => @owner, :id => @id})
        hash = response["event"]
      end
      unless hash.empty?
        @organizer = Organizer.new(@owner, hash.delete('organizer')) if hash['organizer']
        @venue = Venue.new(@owner, hash.delete('venue')) if hash['venue']
        init_with_hash(hash, ['tickets'])
      end
    end
    
    def save
      opts = {:user => @owner}
      opts.merge!(update_hash)
      opts[:privacy] = privacy if opts[:privacy]      # Fix privacy formatting
      opts[:timezone] = timezone if opts[:timezone]   # Fix Timezone formatting
      if loaded?
        opts.merge! :event_id => @id  # Another api inconsistency... how suprising
        EventBright.call(:event_update, opts)
      else
        @owner.dirty_events!
        EventBright.call(:event_new, opts)
      end
    end
    
  end
  class EventCollection < ApiObjectCollection; collection_for Event; end
end