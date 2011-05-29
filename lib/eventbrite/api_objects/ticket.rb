module Eventbrite
  
  # Each event may have multiple available tickets.
  class Ticket < ApiObject
    
    updatable :is_donation
    updatable :name, :description 
    updatable :price, :quantity
    updatable :include_fee
    updatable :min, :max
    updatable :hide
    updatable_date :start_sales, :end_sales
    readable  :quantity_sold, :currency
    attr_accessor :event
    
    # @private
    # Remapping some API inconsistencies 
    remap :type => :is_donation, :visible => :hide, :quantity_available => :quantity
    remap :end_date => :end_sales, :start_date => :start_sales
    
    requires  :name, :price, :quantity
    reformats :hide
    
    # Tickets can't live outside events, so we override standard owner to be event.
    def initialize(event = nil, hash = {})
      preinit
      raise ArgumentError unless event.is_a? Eventbrite::Event
      @id = hash.delete(:id)
      @event = event
      @owner = event.owner
      init_with_hash(hash, true)
    end
    
    def visible=(val,*args) 
      val == "1" || val == 1 ? attribute_set(:hide, 0, true) : attribute_set(:hide, 1, true)
    end
    
    def hide
      (["1", 1, "y", "Y"].include? attribute_get(:hide)) ? "y" : "n"
    end
    
    def new_hash
      {:event_id => @event.id}
    end
    
    def after_new
      @event.dirty_tickets!
    end
    
    def after_save
      @event.dirty_tickets!
    end
    
    def after_attribute_set
      @event.dirty_tickets! unless @event.nil?
    end
  end
  class TicketCollection < ApiObjectCollection
    collection_for Ticket
    getter :event_get
    def initialize(owner = false, hash_array = [], event = false)
      super(event, hash_array)
    end
  end
end
