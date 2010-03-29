require 'httparty'
require 'eventbright/helpers'

module EventBright
  include HTTParty
  base_uri "https://www.eventbrite.com/json/" 
  
  def self.setup(app_key = "YmRmMmMxMjYzNDYy", debug = false)
    @app_key = app_key
    @debug = debug
  end
  
  def self.call(function, opts = {}, debug = true)
    @app_key ||= "YmRmMmMxMjYzNDYy"
    debug ||= debug?
    opts[:app_key] = @app_key
    if opts[:user].is_a? EventBright::User
      u = opts.delete :user
      opts.merge!(u.auth)
    end # Allow passing User object instead of user auth info.
    response = get("/#{function}", :query => opts)
    if response["error"]
      raise Error.new(response["error"]["error_message"])
    end
    puts "Response for /#{function} : #{response.inspect[0..80]}..." if debug
    response
  end
  
  def self.debug?
    @debug.nil? ? @debug : false
  end
end