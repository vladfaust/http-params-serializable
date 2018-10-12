require "../spec_helper"

struct HTTPQuery::NullSpec
  Params.mapping({id: Union(Int32, Null)})

  describe self do
    klass = self

    it do
      self.new(req("/?id=null")).id.should be_a Null
    end

    it do
      expect_raises Params::MissingError do
        klass.new(req("/?"))
      end
    end

    it do
      self.new(req("/?id=42")).id.should eq 42
    end
  end
end
