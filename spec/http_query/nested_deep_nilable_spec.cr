require "../spec_helper"

struct HTTPQuery::NestedDeepNilableSpec
  Params.mapping({
    user: {
      name: String,
      meta: {
        bio: String,
      } | Nil,
    },
  })

  describe self do
    klass = self

    it do
      params = self.new(req("/?user[name]=foo&user[meta][bio]=bar"))
      params.user.name.should eq "foo"
      params.user.meta.try &.bio.should eq "bar"
    end

    it "does not raise when user[meta] is missing" do
      params = self.new(req("/?user[name]=foo"))
      params.user.name.should eq "foo"
      params.user.meta.should be_nil
    end

    it "raises when user[meta][bio] is missing" do
      expect_raises Params::MissingError do
        klass.new(req("/?user[name]=foo&user[meta][notBio]=bar"))
      end
    end
  end
end
