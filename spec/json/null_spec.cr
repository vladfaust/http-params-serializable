require "../spec_helper"

struct JSON::NullSpec
  Params.mapping({id: Union(Int32, Null, Nil)})

  describe self do
    it do
      self.new(json({"id" => nil})).id.should eq Null
    end

    it do
      self.new(json({} of String => String)).id.should be_nil
    end

    it do
      self.new(json({"id" => 42})).id.should eq 42
    end
  end
end
