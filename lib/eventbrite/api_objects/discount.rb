module Eventbrite
  
  # Discounts are available for events. You can set either amount_off or
  # percent_off.
  #
  # A discount code must be set.
  class Discount < ApiObject
    
    updatable :code
    updatable :amount_off, :percent_off 
    updatable :tickets 
    updatable :quantity_available
    updatable_date :start_date, :end_date
    readable :quantity_sold
    
    requires :code
    
    # Discounts can't live outside {Eventbrite::Event events} - you must
    # pass an event as the first argument.
    # @raise [ArgumentError] raises an argument error unless an
    #   Eventbrite::Event is passed
    def initialize(event = nil, hash = {})
      preinit
      raise ArgumentError unless event.is_a? Eventbrite::Event
      @id = hash.delete(:id)
      @event = event
      @owner = event.owner
      init_with_hash(hash, true)
    end
    
    # Allows setting the id via discount_id
    def discount_id=(val, no_dirty = false)
      self.id = val
    end
    
    # @private
    # Discounts must have an attached event id to be created.
    def new_hash
      {:event_id => @event.id}
    end
    
    # @private
    # Mark event as dirty if a discount is created
    def after_new
      @event.dirty_discounts!
    end
    
    # @private
    # Mark event as dirty if a discount is edited
    def after_save
      @event.dirty_discounts!
    end

    # @private
    # Mark event as dirty if a discount is edited
    def after_attribute_set
      @event.dirty_discounts! unless @event.nil?
    end
    
    # Only one of amount_off and percent_off can be set.
    def amount_off=(val, no_dirty = false)
      attribute_set(:amount_off, val, no_dirty)
      attribute_set(:percent_off, "", no_dirty)
    end

    
    # Only one of amount_off and percent_off can be set.
    def percent_off=(val, no_dirty = false)
      attribute_set(:percent_off, val, no_dirty)
      attribute_set(:amount_off, "", no_dirty)
    end
  end

  # Represents a list of all {Eventbrite::Discount discounts} for an
  # {Eventbrite::Event event}.
  class DiscountCollection < ApiObjectCollection
    collection_for Discount
    getter :event_list_discounts
    def initialize(owner = false, hash_array = [], event = false)
      super(event, hash_array)
    end
  end
end
