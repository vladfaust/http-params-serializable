require "../spec_helper"

struct HTTPQuery::SimpleNilableSpec
  Params.mapping({id: Int32?})

  describe self do
    it do
      self.new(req("/?id=42")).id.should eq 42
    end

    it "does not raise when id is missing" do
      self.new(req("/")).id.should be_nil
    end
  end
end
