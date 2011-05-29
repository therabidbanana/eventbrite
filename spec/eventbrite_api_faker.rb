def fake_response(call)
  string = ""
  File.open("spec/faked_responses#{call}.json", "r") do |infile|
    while(line = infile.gets)
      string << line
    end
  end
  HTTParty::Response.new(call, FakeResponse.new, HTTParty::Parser.call(string, :json))
end

class FakeResponse
  def body
    ""
  end
  def to_hash
    {}
  end
end


module Eventbrite
  class API
    def self.do_post(string, opts = {})
      fake_response(string)
    end
  end
end
