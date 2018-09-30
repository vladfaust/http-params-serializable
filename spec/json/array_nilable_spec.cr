require "../spec_helper"

struct JSON::ArrayNilableSpec
  Params.mapping({
    foo_array: Array(Int32) | Nil,
    bar_array: Array(Int32)?,
  })

  describe self do
    it do
      params = self.new(json({"fooArray" => [42], "barArray" => [43]}))
      params.foo_array.should eq [42]
      params.bar_array.should eq [43]
    end

    it "does not raise when foo_array is missing" do
      self.new(json({"barArray" => [43]})).foo_array.should be_nil
    end

    it "does not raise when bar_array is missing" do
      self.new(json({"fooArray" => [42]})).bar_array.should be_nil
    end
  end
end
