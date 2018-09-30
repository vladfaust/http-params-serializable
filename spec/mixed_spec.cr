require "./spec_helper"

struct MixedSpec
  Params.mapping({
    id:              Int32,
    active:          Bool?,
    additional_info: {
      email:     String,
      tags:      Array(UInt32),
      deep_info: {
        foo: Float64,
      } | Nil,
    },
  })

  describe self do
    context "JSON" do
      request = HTTP::Request.new(
        "GET",
        headers: HTTP::Headers{"Content-Type" => "application/json"},
        resource: "/?id=42&active=true",
        body: {
          "active"          => false,
          "additional_info" => {
            "email"     => "foo@example.com",
            "tags"      => [42, 43],
            "deep_info" => {
              "foo" => 10_000.0,
            },
          },
        }.to_json)

      it do
        params = self.new(request)
        params.id.should eq 42        # Read from resource params
        params.active.should eq false # Overwritten by JSON
        params.additional_info.email.should eq "foo@example.com"
        params.additional_info.tags.should eq [42_u32, 43_u32]
        params.additional_info.deep_info.not_nil!.foo.should eq 10_000.0_f64
      end
    end
  end
end
