require "../spec_helper"

struct SimpleParams
  include HTTP::Params::Serializable
  getter required : Int32
  getter optional : Bool | Char | String | Int32 | Float32 | Nil
end

describe SimpleParams do
  describe "required" do
    v = SimpleParams.new("required=42&unknown=foo")

    describe "parsing" do
      it do
        v.required.should be_a(Int32)
        v.required.should eq 42
      end

      it "raises on missing" do
        assert_raise(
          SimpleParams,
          "unknown=foo",
          HTTP::Params::Serializable::ParamMissingError,
          "Parameter \"required\" is missing",
          ["required"]
        )
      end

      it "raises on empty" do
        assert_raise(
          SimpleParams,
          "required=&unknown=foo",
          HTTP::Params::Serializable::ParamMissingError,
          "Parameter \"required\" is missing",
          ["required"]
        )
      end

      it "raises on type mismatch" do
        assert_raise(
          SimpleParams,
          "required=foo",
          HTTP::Params::Serializable::ParamTypeCastError,
          "Parameter \"required\" cannot be cast from \"foo\" to Int32",
          ["required"],
        )
      end
    end

    describe "serializing" do
      it do
        v.to_http_param.should eq "required=42"
      end
    end
  end

  describe "optional" do
    it "casts to Bool" do
      v = SimpleParams.new("required=42&optional=true")
      v.optional.should be_a(Bool)
      v.optional.should eq true
      v.to_http_param.should eq "required=42&optional=true"
    end

    it "casts to Char" do
      v = SimpleParams.new("required=42&optional=t")
      v.optional.should be_a(Char)
      v.optional.should eq 't'
      v.to_http_param.should eq "required=42&optional=t"
    end

    it "casts to String" do
      v = SimpleParams.new("required=42&optional=foo")
      v.optional.should be_a(String)
      v.optional.should eq "foo"
      v.to_http_param.should eq "required=42&optional=foo"
    end

    it "casts to Float32 instead of Int32" do
      v = SimpleParams.new("required=42&optional=42")
      v.optional.should be_a(Float32)
      v.optional.should eq 42.0
      v.to_http_param.should eq "required=42&optional=42.0"
    end

    it "casts to Float32" do
      v = SimpleParams.new("required=42&optional=-42.1")
      v.optional.should be_a(Float32)
      v.optional.should eq -42.1_f32
      v.to_http_param.should eq "required=42&optional=-42.1"
    end

    it "stays nil on empty" do
      v = SimpleParams.new("required=42&optional=")
      v.optional.should be_nil
      v.to_http_param.should eq "required=42"
    end

    it "stays nil on missing" do
      v = SimpleParams.new("required=42")
      v.optional.should be_nil
      v.to_http_param.should eq "required=42"
    end
  end
end
