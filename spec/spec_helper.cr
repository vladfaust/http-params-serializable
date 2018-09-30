require "spec"
require "../src/params"

class HTTP::Request
  property resource_params : Hash(String, String) | Nil = nil
end

def req(resource : String)
  HTTP::Request.new("GET", resource)
end

def json(hash : Hash)
  HTTP::Request.new("POST", "/", body: hash.to_json, headers: HTTP::Headers{"Content-Type" => "application/json"})
end

def form_data(&block)
  io = IO::Memory.new

  builder = HTTP::FormData::Builder.new(io, "boundary")
  yield(builder)
  builder.finish

  HTTP::Request.new("POST", "/", body: io.to_s, headers: HTTP::Headers{"Content-Type" => builder.content_type})
end
