require "../spec_helper"

struct JSON::SimpleNilableSpec
  Params.mapping({id: Int32?})

  describe self do
    it do
      self.new(json({"id" => 42})).id.should eq 42
    end

    it "does not raise when id is missing" do
      self.new(json({} of String => String)).id.should be_nil
    end
  end
end
