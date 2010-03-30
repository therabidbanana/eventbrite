module EventBright
  class User < EventBright::ApiObject
    
    updatable :email, :password
    readable :user_key
    readable :first_name, :last_name
    readable_date :date_created, :date_modified
    remap :user_id => :id
    ignores ['subusers']
    def initialize(user, no_load = false)
      case user
      when Array
        email, password = user
        attribute_set(:email, email, true)
        attribute_set(:password, password, true)
      else
        attribute_set(:user_key, user, true)
      end
      @events = @venues = @organizers = []
      @dirty_events = @dirty_venues = @dirty_organizers = true
      load! unless no_load
    end
    
    def prep_api_hash(method = 'get', hash = {})
      {:user => self}
    end
    
    def venues
      return @venues if @venues && !@dirty_venues
      response = EventBright.call(:user_list_venues, {:user => self})
      # EventBrite creates blank venues on occassion. No point in showing them.
      @venues = VenueCollection.new(self, response["venues"], "address")
      @dirty_venues = false
      @venues
    end
    
    def dirty_venues!
      @dirty_venues = true
    end
    
    def dirty_organizers!
      @dirty_organizers = true
    end
    
    def dirty_events!
      @dirty_events = true
    end
    
    def organizers
      return @organizers if @organizers && !@dirty_organizers
      response = EventBright.call(:user_list_organizers, {:user => self})
      # EventBrite creates blank venues on occassion. No point in showing them.
      @organizers = OrganizerCollection.new(self, response["organizers"], "name")
      @dirty_organizers = false
      @organizers
    end
    
    def events
      return @events if @events && !@dirty_events
      response = EventBright.call(:user_list_events, {:user => self})
      # EventBrite creates blank venues on occassion. No point in showing them.
      @events = EventCollection.new(self, response["events"], "title")
      @dirty_events = false
      @events
    end
    
    def auth
      attribute_get(:user_key) ? {'user_key' => attribute_get(:user_key)} : {'user' => attribute_get(:email), 'password' => attribute_get(:password)} 
    end
    
  end
end