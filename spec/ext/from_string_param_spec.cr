# Array.from_strings is sufficient to test all types
describe "Array(T).from_strings" do
  {% for set in [
                  {Bool, ["true", "false"], [true, false]},
                  {Float32, ["0.5", "0.6"], [0.5_f32, 0.6_f32]},
                  {Float64, ["0.5", "0.6"], [0.5, 0.6]},
                  {Int8, ["41", "42"], [41_i8, 42_i8]},
                  {Int16, ["41", "42"], [41_i16, 42_i16]},
                  {Int32, ["41", "42"], [41, 42]},
                  {Int64, ["41", "42"], [41_i64, 42_i64]},
                  {UInt8, ["41", "42"], [41_u8, 42_u8]},
                  {UInt16, ["41", "42"], [41_u16, 42_u16]},
                  {UInt32, ["41", "42"], [41_u32, 42_u32]},
                  {UInt64, ["41", "42"], [41_u64, 42_u64]},
                  {String, ["foo", "bar"], ["foo", "bar"]},
                ] %}
    it "works for Array({{set[0]}}) and #{{{set[1]}}}"do
      Array({{set[0]}}).from_strings({{set[1]}}).should eq {{set[2]}}
    end
  {% end %}

  it "raises when value has wrong type" do
    expect_raises TypeCastError do
      Array(Int32).from_strings(["foo", "bar"])
    end

    expect_raises TypeCastError do
      Array(UInt8).from_strings(["10000"])
    end

    expect_raises TypeCastError do
      Array(Bool).from_strings(["foo"])
    end
  end
end
