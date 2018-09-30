require "../spec_helper"

struct JSON::NestedSpec
  Params.mapping({
    user: {
      name:    String,
      surname: String | Nil,
    },
  })

  describe self do
    klass = self

    it do
      params = self.new(json({"user" => {"name" => "foo", "surname" => "bar"}}))
      params.user.name.should eq "foo"
      params.user.surname.should eq "bar"
    end

    it "raises when user is missing" do
      expect_raises Params::MissingError do
        klass.new(json({"user" => nil}))
      end
    end

    it "raises when user[name] is missing" do
      expect_raises Params::MissingError do
        klass.new(json({"user" => {"surname" => "bar"}}))
      end
    end

    it "does not raise when user[surname] is missing" do
      params = self.new(json({"user" => {"name" => "foo"}}))
      params.user.name.should eq "foo"
      params.user.surname.should be_nil
    end
  end
end
