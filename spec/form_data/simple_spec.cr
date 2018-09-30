require "../spec_helper"

struct FormData::SimpleSpec
  Params.mapping({id: Int32})

  describe self do
    it do
      self.new(form_data do |builder|
        builder.field("id", "42")
      end).id.should eq 42
    end

    it "raises when id is missing" do
      klass = self

      expect_raises Params::MissingError do
        klass.new(form_data do |builder|
          builder.field("not_id", 42)
        end)
      end
    end

    it "raises when id is of wrong type" do
      klass = self

      expect_raises Params::TypeCastError do
        klass.new(form_data do |builder|
          builder.field("id", "foo")
        end)
      end
    end
  end
end
