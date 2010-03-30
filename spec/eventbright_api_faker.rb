def fake_response_with(call, opts)
  call = "/auth_required" if call_requires_auth?(call) && !(opts[:user_key])
  string = ""
  File.open("spec/faked_responses#{call}.json", "r") do |infile|
    while(line = infile.gets)
      string << line
    end
  end
  HTTParty::Response.new(HTTParty::Parser.call(string, "text/json"), string, 200, "")
end

def fake_response(call)
  string = ""
  File.open("spec/faked_responses#{call}.json", "r") do |infile|
    while(line = infile.gets)
      string << line
    end
  end
  HTTParty::Response.new(HTTParty::Parser.call(string, "text/json"), "", 200, "")
end

def call_requires_auth?(call)
  return true if call =~ /user_/
  return true if call =~ /_update/
  return true if call =~ /_new/
  return false
end

module EventBright
  class API
    def self.do_post(string, opts = {})
      fake_response_with(string, opts)
    end
  end
end