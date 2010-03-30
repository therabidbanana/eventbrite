module EventBright
  
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
    
    # Remapping some API inconsistencies
    remap :type => :is_donation, :visible => :hide, :quantity_available => :quantity
    remap :end_date => :end_sales, :start_date => :start_sales
    
    def initialize(event = nil, hash = {})
      raise ArgumentError unless event.is_a? EventBright::Event
      @id = hash.delete(:id)
      @event = event
      init_with_hash(hash, [], true)
      @owner = event.owner
    end
    
    def visible=(val,*args) 
      val == "1" || val == 1 ? attribute_set(:hide, 0, true) : attribute_set(:hide, 1, true)
    end
    
    def hide
      (attribute_get(:hide) == "1" || attribute_get(:hide) == 1) ? "y" : "n"
    end
        
    def save
      opts = {:user => @owner}
      opts.merge!(update_hash(%w(name price quantity)))
      opts[:hide] = hide if opts[:hide]
      call = if loaded?
        @event.dirty_tickets!
        opts.merge! :id => @id
        EventBright.call(:ticket_update, opts)
      else
        @event.dirty_tickets!
        opts.merge! :event_id => @event.id
        EventBright.call(:ticket_new, opts)
      end
      self.id = call["process"]["id"] unless loaded?
      @dirty = {}
      call
    end
    
    def after_attribute_set
      @event.dirty_tickets! unless @event.nil?
    end
  end
  class TicketCollection < ApiObjectCollection
    collection_for Ticket
    def initialize(owner = false, hash_array = [], reject_if_empty = false, event = false)
      super(event, hash_array, reject_if_empty)
    end
  end
end