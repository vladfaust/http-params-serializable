require "../spec_helper"

struct FormData::NestedDeepNilableSpec
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
      params = self.new(form_data do |builder|
        builder.field("user[name]", "foo")
        builder.field("user[meta][bio]", "bar")
      end)
      params.user.name.should eq "foo"
      params.user.meta.try &.bio.should eq "bar"
    end

    it "does not raise when user[meta] is missing" do
      params = self.new(form_data do |builder|
        builder.field("user[name]", "foo")
      end)
      params.user.name.should eq "foo"
      params.user.meta.should be_nil
    end

    it "raises when user[meta][bio] is missing" do
      expect_raises Params::MissingError do
        klass.new(form_data do |builder|
          builder.field("user[name]", "foo")
          builder.field("user[meta][not_bio]", "bar")
        end)
      end
    end
  end
end
