require "../spec_helper"

struct HTTPQuery::NestedSpec
  Params.mapping({
    user: {
      name:    String,
      surname: String | Nil,
    },
  })

  describe self do
    klass = self

    it do
      params = self.new(req("/?user[name]=foo&user[surname]=bar"))
      params.user.name.should eq "foo"
      params.user.surname.should eq "bar"
    end

    it "raises when user is missing" do
      expect_raises Params::MissingError do
        klass.new(req("/"))
      end
    end

    it "raises when user[name] is missing" do
      expect_raises Params::MissingError do
        klass.new(req("/?user[surname]=foo"))
      end
    end

    it "does not raise when user[surname] is missing" do
      params = self.new(req("/?user[name]=foo"))
      params.user.name.should eq "foo"
      params.user.surname.should be_nil
    end
  end
end
