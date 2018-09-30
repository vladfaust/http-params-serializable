require "../spec_helper"

struct HTTPQuery::NestedNilableSpec
  Params.mapping({
    user: {
      name: String,
    } | Nil,
  })

  describe self do
    klass = self

    it do
      self.new(req("/?user[name]=foo")).user.try &.name.should eq "foo"
    end

    it "does not raise when user is missing" do
      self.new(req("/")).user.should be_nil
    end

    it "raises when user[name] is missing" do
      expect_raises Params::MissingError do
        klass.new(req("/?user[notName]=foo"))
      end
    end
  end
end
