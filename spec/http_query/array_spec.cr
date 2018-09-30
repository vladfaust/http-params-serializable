require "../spec_helper"

struct HTTPQuery::ArraySpec
  Params.mapping({id: Array(Int32)})

  describe self do
    it do
      self.new(req("/?id[]=42&id[]=43")).id.should eq [42, 43]
    end

    it "raises when id is missing" do
      klass = self

      expect_raises Params::MissingError do
        klass.new(req("/"))
      end
    end
  end
end
