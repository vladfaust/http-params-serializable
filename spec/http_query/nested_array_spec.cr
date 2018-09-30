require "../spec_helper"

struct HTTPQuery::NestedArraySpec
  Params.mapping({
    user: {
      names: Array(String),
    },
  })

  describe self do
    it do
      self.new(req("/?user[names][]=foo&user[names][]=bar")).user.names.should eq ["foo", "bar"]
    end
  end
end
