require "../spec_helper"

struct FormData::NullSpec
  Params.mapping({id: Union(Int32, Null, Nil)})

  describe self do
    it do
      self.new(form_data do |builder|
        builder.field("id", "null")
      end).id.should eq Null
    end

    it do
      self.new(form_data do |builder|
        builder.field("notid", "null")
      end).id.should be_nil
    end

    it do
      self.new(form_data do |builder|
        builder.field("id", "42")
      end).id.should eq 42
    end
  end
end
