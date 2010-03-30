module EventBright
  class User < EventBright::ApiObject
    
    updatable :email, :password
    readable :user_key
    readable :first_name, :last_name
    readable_date :date_created, :date_modified
    remap :user_id => :id
    ignores ['subusers']
    
    collection :events => EventBright::EventCollection
    collection :organizers => EventBright::OrganizerCollection
    collection :venues => EventBright::VenueCollection
    
    def initialize(user, no_load = false)
      preinit
      case user
      when Array
        email, password = user
        attribute_set(:email, email, true)
        attribute_set(:password, password, true)
      else
        attribute_set(:user_key, user, true)
      end
      load! unless no_load
    end
    
    def prep_api_hash(method = 'get', hash = {})
      {:user => self}
    end
    
    def unnest_child_response(response)
      response
    end
    
    def owner
      self
    end
    
    def auth
      attribute_get(:user_key) ? {'user_key' => attribute_get(:user_key)} : {'user' => attribute_get(:email), 'password' => attribute_get(:password)} 
    end
    
  end
end