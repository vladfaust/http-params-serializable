require "../spec_helper"

struct JSON::SimpleSpec
  Params.mapping({id: Int32})

  describe self do
    it do
      self.new(json({"id" => 42})).id.should eq 42
    end

    it "raises when id is missing" do
      klass = self

      expect_raises Params::MissingError do
        klass.new(json({} of String => String))
      end
    end

    it "raises when id is of wrong type" do
      klass = self

      expect_raises Params::TypeCastError do
        klass.new(json({"id" => "42"}))
      end
    end
  end
end
