module Eventbrite
  class Error < Exception
    attr_accessor :type, :response, :message
    def initialize(message, type = "", response = nil)
      @type = type
      @response = response
      @message = message
      super(message)
    end
    def inspect
      "<Eventbrite::Error(#{type}): #{message}>"
    end
  end
end
