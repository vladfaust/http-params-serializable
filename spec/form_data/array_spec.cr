require "../spec_helper"

struct FormData::ArraySpec
  Params.mapping({ids: Array(Int32)})

  describe self do
    it do
      self.new(form_data do |builder|
        builder.field("ids[]", 42)
        builder.field("ids[]", 43)
      end).ids.should eq [42, 43]
    end

    it "raises when ids is missing" do
      klass = self

      expect_raises Params::MissingError do
        klass.new(form_data do |builder|
          builder.field("not_ids[]", 42)
        end)
      end
    end
  end
end
