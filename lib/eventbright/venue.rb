module EventBright
  
  class Venue < ApiObject
    
    updatable :name
    updatable :address, :address_2 
    updatable :city, :region, :postal_code 
    updatable :country, :country_code
    readable :latitude, :longitude
    renames :name => :venue, :address => :adress, :address_2 => :adress_2
    
    def initialize(owner = user, hash = {})
      @id = hash.delete(:id)
      hash.delete('Lat-Long') # Trash the Lat-Long. We don't care.
      init_with_hash(hash, true)
      @owner = owner
    end
    
    def state;        region;       end    # Region is same as state in US
    def state=(val);  region= val;  end    # Region is same as state in US
  end
  class VenueCollection < ApiObjectCollection; collection_for Venue; end
end