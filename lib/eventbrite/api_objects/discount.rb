module Eventbrite
  
  class Discount < ApiObject
    
    updatable :code
    updatable :amount_off, :percent_off 
    updatable :tickets 
    updatable :quantity_available
    updatable_date :start_date, :end_date
    readable :quantity_sold
    
    requires :code
    
    # Tickets can't live outside events, so we override standard owner to be event.
    def initialize(event = nil, hash = {})
      preinit
      raise ArgumentError unless event.is_a? Eventbrite::Event
      @id = hash.delete(:id)
      @event = event
      @owner = event.owner
      init_with_hash(hash, true)
    end
    
    def discount_id=(val, no_dirty = false)
      self.id = val
    end
    
    def new_hash
      {:event_id => @event.id}
    end
    
    
    def after_new
      @event.dirty_discounts!
    end
    
    def after_save
      @event.dirty_discounts!
    end
    
    def after_attribute_set
      @event.dirty_discounts! unless @event.nil?
    end
    
    def amount_off=(val, no_dirty = false)
      attribute_set(:amount_off, val, no_dirty)
      attribute_set(:percent_off, "", no_dirty)
    end

    def percent_off=(val, no_dirty = false)
      attribute_set(:percent_off, val, no_dirty)
      attribute_set(:amount_off, "", no_dirty)
    end
  end
  class DiscountCollection < ApiObjectCollection
    collection_for Discount
    getter :event_list_discounts
    def initialize(owner = false, hash_array = [], event = false)
      super(event, hash_array)
    end
  end
end
