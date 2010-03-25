require 'httparty'

module EventBright
  include HTTParty
  base_uri "https://www.eventbrite.com/json/" 
  
  def self.setup(app_key = "YmRmMmMxMjYzNDYy")
    @app_key = app_key
  end
  
  def self.call(function, opts = {})
    @app_key ||= "YmRmMmMxMjYzNDYy"
    opts[:app_key] = @app_key
    if opts[:user].is_a? EventBright::User
      u = opts.delete :user
      opts.merge!(u.auth)
    end # Allow passing User object instead of user auth info.
    response = get("/#{function}", :query => opts)
    if response["error"]
      raise Error.new(response["error"]["error_message"])
    end
    response
  end
  
  class Error < Exception
  end
  
  class User
    attr_accessor :user_key, :user, :password
    def initialize(user)
      if user.is_a? Array
        @user, @password = user
      else
        @user_key = user
      end
    end
    
    def venues
      response = EventBright.call(:user_list_venues, {:user => self})
      # EventBrite creates blank venues on occassion. No point in showing them.
      venues = response["venues"].map{|v| v["venue"]}.reject{|v| v["address"] == ""}
      venues.map{|v| Venue.new(v)}
    end
    
    def organizers
      EventBright.call(:user_list_organizers, {:user => self})
    end
    
    def events
      EventBright.call(:user_list_events, {:user => self})
    end
    
    def auth
      @user_key ? {'user_key' => @user_key} : {'user' => @user, 'password' => @password} 
    end
    
  end
  
  class Venue
    attr_accessor :id, :name, :address, :address_2 
    attr_accessor :city, :region, :postal_code 
    attr_accessor :country, :country_code
    attr_accessor :latitude, :longitude
    def initialize(hash = {})
      hash.each{|k, v| self.__send__("#{k}=", v)}
    end
  end
  
  class Event
    
  end
end