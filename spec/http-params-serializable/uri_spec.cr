require "../spec_helper"
require "../../src/http-params-serializable/ext/uri"

# Used to test explict Scalar objects
# Note that any value is considered valid for an URI
struct URIParams
  include HTTP::Params::Serializable

  getter uri : URI
  getter nilable_uri : URI?
  getter array_uri : Array(URI)
  getter nilable_array_uri : Array(URI)?
  getter array_nilable_uri : Array(URI?)
  getter nilable_array_nilable_uri : Array(URI?)?
end

describe URIParams do
  it do
    v = URIParams.new("uri=https://example.com&nilable_uri=foo&array_uri[0]=bar&nilable_array_uri[]=baz&array_nilable_uri[]=&nilable_array_nilable_uri[0]=")
    v.uri.should eq URI.parse("https://example.com")
    v.nilable_uri.should eq URI.parse("foo")
    v.array_uri.should eq [URI.parse("bar")]
    v.nilable_array_uri.should eq [URI.parse("baz")]
    v.array_nilable_uri.should eq [nil]
    v.nilable_array_nilable_uri.should eq [nil]

    v.to_http_param.should eq escape("uri=https://example.com&nilable_uri=foo&array_uri[]=bar&nilable_array_uri[]=baz")
  end
end
