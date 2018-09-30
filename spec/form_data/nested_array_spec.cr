require "../spec_helper"

struct FormData::NestedArraySpec
  Params.mapping({
    user: {
      names: Array(String),
    },
  })

  describe self do
    it do
      self.new(form_data do |builder|
        builder.field("user[names][]", "foo")
        builder.field("user[names][]", "bar")
      end).user.names.should eq ["foo", "bar"]
    end
  end
end
