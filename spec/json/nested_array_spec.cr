require "../spec_helper"

struct JSON::NestedArraySpec
  Params.mapping({
    user: {
      names: Array(String),
    },
  })

  describe self do
    it do
      self.new(json({"user" => {"names" => ["foo", "bar"]}})).user.names.should eq ["foo", "bar"]
    end
  end
end
