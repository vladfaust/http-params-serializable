require "../spec_helper"

struct HTTPQuery::SimpleSpec
  Params.mapping({id: Int32})

  describe self do
    it do
      self.new(req("/?id=42")).id.should eq 42
    end

    it "raises when id is missing" do
      klass = self

      expect_raises Params::MissingError do
        klass.new(req("/"))
      end
    end
  end
end
