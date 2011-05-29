require 'eventbrite/api_objects/ticket'
module Eventbrite
  
  class Attendee < ApiObject
    
    readable :quantity, :currency, :amount_paid
    readable :barcode, :order_id, :order_type
    readable_date :created, :modified, :event_date
    readable :discount, :notes
    readable :email
    readable :prefix, :first_name, :last_name, :suffix
    readable :home_address, :home_address_2, :home_city, :home_postal_code
    readable :home_country_code, :home_country, :home_region, :home_phone, :cell_phone
    readable :ship_address, :ship_address_2, :ship_city, :ship_postal_code
    readable :ship_country_code, :ship_country, :ship_region
    readable :work_address, :work_address_2, :work_city, :work_postal_code
    readable :work_country_code, :work_country, :work_region, :work_phone
    readable :job_title, :company, :website, :blog, :gender
    readable :age, :birth_date
    readable :affiliate # Doc error - affiliate?
    ignores :answers
    readable :event_id
    
    readable :ticket_id
    attr_accessor :event
    
    
    # Attendees can't live outside events, so we override standard owner to be event.
    def initialize(event = nil, hash = {})
      preinit
      raise ArgumentError unless event.is_a? Eventbrite::Event
      @id = hash.delete(:id)
      @event = event
      @owner = event.owner
      init_with_hash(hash, true)
    end
    
    def save(*args)
      # noop. Attendees can't be altered via api
    end
  end
  class AttendeeCollection < ApiObjectCollection
    collection_for Attendee
    getter :event_list_attendees
    def initialize(owner = false, hash_array = [], event = false)
      super(event, hash_array)
    end
    def save(*args)
      # noop. Attendees can't be altered via api
    end
  end
end
