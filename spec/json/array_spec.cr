require "../spec_helper"

struct JSON::ArraySpec
  Params.mapping({ids: Array(Int32)})

  describe self do
    it do
      self.new(json({"ids" => [42, 43]})).ids.should eq [42, 43]
    end

    it "raises when ids is missing" do
      klass = self

      expect_raises Params::MissingError do
        klass.new(json({} of String => String))
      end
    end
  end
end
