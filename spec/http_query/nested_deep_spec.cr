require "../spec_helper"

struct HTTPQuery::NestedDeepSpec
  Params.mapping({
    user: {
      name: String,
      meta: {
        bio: String,
      },
    },
  })

  describe self do
    klass = self

    it do
      params = self.new(req("/?user[name]=foo&user[meta][bio]=bar"))
      params.user.name.should eq "foo"
      params.user.meta.bio.should eq "bar"
    end

    it "raises when user[meta] is missing" do
      expect_raises Params::MissingError do
        klass.new(req("/?user[name]=foo"))
      end
    end

    it "raises when user[meta][bio] is missing" do
      expect_raises Params::MissingError do
        klass.new(req("/?user[name]=foo&user[meta][notBio]=bar"))
      end
    end
  end
end
