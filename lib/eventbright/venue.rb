module EventBright
  class Venue
    include EventBright::ApiObject
    
    updatable :name
    updatable :address, :address_2 
    updatable :city, :region, :postal_code 
    updatable :country, :country_code
    attr_accessor :latitude, :longitude
    def initialize(owner = user, hash = {})
      @id = nil
      init_with_hash(hash)
      @owner = owner
    end
    
    def save
      opts = {:user => @owner}
      opts.merge!(update_hash)
      opts[:venue] = opts[:name]      # eventbrite api fails at consistency (Case: #46349)
      opts[:adress] = opts[:address]  # eventbrite api fails at spelling  (Case: #46346)
      opts[:adress_2] = opts[:address_2]
      if loaded?
        opts.merge! :id => @id
        EventBright.call(:venue_update, opts)
      else
        @owner.dirty_venues!
        EventBright.call(:venue_new, opts)
      end
    end
    
    def state;        @region;      end    # Region is same as state in US
    def state=(val);  region= val;  end    # Region is same as state in US
  end
end