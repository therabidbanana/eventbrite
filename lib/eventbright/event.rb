module EventBright
  class Event
    def initialize(hash = {})
      EventBright.init_with_hash(self, hash)
    end
  end
end