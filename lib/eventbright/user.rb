module EventBright
  class User < EventBright::ApiObject
    
    updatable :email, :password
    attr_accessor :user_key
    attr_accessor :first_name, :last_name
    attr_accessor :date_created, :date_modified 
    def initialize(user, hash = {})
      case user
      when Array
        @email, @password = user
      else
        @user_key = user
      end
      @venues = @organizers = []
      @dirty_venues = @dirty_organizers = true
      load
    end
    
    def date_created=(date);  @date_created  = Time.parse(date);  end
    def date_modified=(date); @date_modified = Time.parse(date);  end
    def user_id=(new_id);     @id = new_id.to_int;                end
    def user_id; @id; end
    
    def load(hash = {})
      if hash.empty?
        response = EventBright.call(:user_get, {:user => self})
        hash = response["user"]
      end
      unless hash.empty?
        init_with_hash(hash, ['subusers'])
      end
    end
    
    # Save updated email or password
    def save
      opts = {:user => self}
      opts.merge!{update_hash}
      EventBright.call(:user_update, opts)
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
    
    def organizers
      return @organizers if @organizers && !@dirty_organizers
      response = EventBright.call(:user_list_organizers, {:user => self})
      # EventBrite creates blank venues on occassion. No point in showing them.
      @organizers = OrganizerCollection.new(self, response["organizers"], "name")
      @dirty_organizers = false
      @organizers
    end
    
    def events
      response = EventBright.call(:user_list_events, {:user => self})
      events = response["events"].map{|e| e["event"]}
      events.map{|e| Event.new(self, e)}
    end
    
    def auth
      @user_key ? {'user_key' => @user_key} : {'user' => @email, 'password' => @password} 
    end
    
  end
end