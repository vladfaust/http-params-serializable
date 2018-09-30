require "../spec_helper"

struct FormData::NestedSpec
  Params.mapping({
    user: {
      name:    String,
      surname: String | Nil,
    },
  })

  describe self do
    klass = self

    it do
      params = self.new(form_data do |builder|
        builder.field("user[name]", "foo")
        builder.field("user[surname]", "bar")
      end)
      params.user.name.should eq "foo"
      params.user.surname.should eq "bar"
    end

    it "raises when user is missing" do
      expect_raises Params::MissingError do
        klass.new(form_data do |builder|
          builder.field("not_a_user", "foo")
        end)
      end
    end

    it "raises when user[name] is missing" do
      expect_raises Params::MissingError do
        klass.new(form_data do |builder|
          builder.field("user[surname]", "bar")
        end)
      end
    end

    it "does not raise when user[surname] is missing" do
      params = self.new(form_data do |builder|
        builder.field("user[name]", "foo")
      end)
      params.user.name.should eq "foo"
      params.user.surname.should be_nil
    end
  end
end
