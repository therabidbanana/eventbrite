def fake_response(call)
  string = ""
  File.open("spec/faked_responses#{call}.json", "r") do |infile|
    while(line = infile.gets)
      string << line
    end
  end
  HTTParty::Response.new(HTTParty::Parser.call(string, :json), string, 200, "")
end


module EventBright
  class API
    def self.do_post(string, opts = {})
      fake_response(string)
    end
  end
end