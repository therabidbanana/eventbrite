module Eventbrite
  
  class Venue < ApiObject
    
    updatable :name
    updatable :address, :address_2 
    updatable :city, :region, :postal_code 
    updatable :country, :country_code
    updatable :organizer_id
    readable :latitude, :longitude
    requires :name
    renames :name => :venue, :address => :adress, :address_2 => :adress_2
    ignores :"Lat-Long"
    
    # Region is same as state in US
    def state;        region;       end 
    # Region is same as state in US
    def state=(val);  region= val;  end 
  end
  class VenueCollection < ApiObjectCollection; collection_for Venue; end
end
