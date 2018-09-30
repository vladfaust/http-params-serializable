# Array.from_json_param is sufficient to test all types
# describe "Array(T).from_json_param" do
#   {% for type, example in {
#                             Bool    => [true, false],
#                             Float32 => [0.5_f32, 0.6_f32],
#                             Float64 => [0.5, 0.6],
#                             Int8    => [41_i8, 42_i8],
#                             Int16   => [41_i16, 42_i16],
#                             Int32   => [41, 42],
#                             Int64   => [41_i64, 42_i64],
#                             UInt8   => [41_u8, 42_u8],
#                             UInt16  => [41_u16, 42_u16],
#                             UInt32  => [41_u32, 42_u32],
#                             UInt64  => [41_u64, 42_u64],
#                             UInt128 => [41_u128, 42_u128],
#                             String  => ["foo", "bar"],
#                           } %}
#     it "works for Array({{type}}) and #{{{example}}}"do
#       Array({{type}}).from_json_param(JSON.parse({{example}}.to_json)).should eq {{example}}
#     end
#   {% end %}

#   it "raises when value has wrong type" do
#     expect_raises TypeCastError do
#       Array(Int32).from_json_param(JSON.parse(["foo", "bar"].to_json))
#     end

#     expect_raises TypeCastError do
#       Array(String).from_json_param(JSON.parse([41, 42].to_json))
#     end

#     expect_raises TypeCastError do
#       Array(UInt8).from_json_param(JSON.parse([10000].to_json))
#     end

#     expect_raises TypeCastError do
#       Array(Bool).from_json_param(JSON.parse(["true"].to_json))
#     end
#   end
# end
