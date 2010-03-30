require 'tzinfo'
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
    attr_accessor :organizer, :venue
    def initialize(owner = user, hash = {})
      @id = hash.delete(:id)
      @organizer = Organizer.new(owner, hash.delete('organizer')) if hash['organizer']
      @venue = Venue.new(owner, hash.delete('venue')) if hash['venue']
      tickets = hash.delete('tickets')
      init_with_hash(hash)
      @owner = owner
      @tickets = TicketCollection.new(@owner, tickets, "name", self) if tickets
      @dirty_organizer = @dirty_venue = @dirty_tickets = false
    end
    
    def privacy
      case attribute_get(:privacy)
      when "Private"
        attribute_set(:privacy, 0)
      when "Public"
        attribute_set(:privacy, 1)
      end
      attribute_get(:privacy)
    end
    
    def owner
      @owner
    end
        
    def currency
      attribute_get(:currency) || attribute_set(:currency, "USD")
    end
    
    def organizer=(val)
      @dirty_organizer = true
      @organizer = val
    end
    
    def venue=(val)
      @dirty_venue = true
      @venue = val
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
    
    def load(hash = {})
      if hash.empty?
        response = EventBright.call(:event_get, {:user => @owner, :id => @id})
        hash = response["event"]
      end
      unless hash.empty?
        @organizer = Organizer.new(@owner, hash.delete('organizer')) if hash['organizer']
        @venue = Venue.new(@owner, hash.delete('venue')) if hash['venue']
        init_with_hash(hash, ['tickets'])
        @tickets = TicketCollection.new(@owner, hash['tickets'], "name", self) if hash['tickets']
      end
    end
    
    def save
      opts = {:user => @owner}
      opts.merge!(update_hash)
      opts[:privacy] = privacy if opts[:privacy]      # Fix privacy formatting
      opts[:timezone] = timezone if opts[:timezone]   # Fix Timezone formatting
      opts[:start_date] = start_date if opts[:start_date] # Fix Date formatting
      opts[:end_date] = end_date if opts[:end_date]       # Fix date formatting
      @organizer.save if @organzier && @organizer.dirty?
      @venue.save if @venue && @venue.dirty?
      opts[:organizer_id] = @organizer.id if @dirty_organizer
      opts[:venue_id] = @venue.id if @dirty_venue
      call = if loaded?
        opts.merge! :event_id => @id  # Another api inconsistency... how suprising
        EventBright.call(:event_update, opts)
      else
        @owner.dirty_events!
        EventBright.call(:event_new, opts)
      end
      unless loaded?
        self.id = call["process"]["id"]
        self.load # Make sure we're fully up-to-date
      end
      @tickets.save if @dirty_tickets
      @dirty = {}
      call
    end
    
    def dirty_tickets!
      @dirty_tickets = true
    end
    
    def tickets
      return @tickets if @tickets && !@dirty_tickets
      response = EventBright.call(:event_get, {:user => @owner, :id => @id})
      # EventBrite creates blank venues on occassion. No point in showing them.
      @tickets = TicketCollection.new(@owner, response["event"]["tickets"], "name", self)
      @dirty_tickets = false
      @tickets
    end
    
  end
  class EventCollection < ApiObjectCollection; collection_for Event; end
end