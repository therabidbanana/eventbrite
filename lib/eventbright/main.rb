require 'httparty'
require 'eventbright/helpers'

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
  
  
end