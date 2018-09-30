require "../spec_helper"

struct HTTPQuery::SimpleMultipleSpec
  Params.mapping({foo: Int32, bar: Int32?})

  describe self do
    klass = self

    it do
      params = self.new(req("/?foo=1&bar=2"))
      params.foo.should eq 1
      params.bar.should eq 2
    end

    context "when foo is missing" do
      it "raises" do
        expect_raises Params::MissingError do
          klass.new(req("/?bar=2"))
        end
      end
    end

    context "when bar is missing" do
      it "does not raise" do
        params = self.new(req("/?foo=1"))
        params.foo.should eq 1
        params.bar.should be_nil
      end
    end
  end
end
