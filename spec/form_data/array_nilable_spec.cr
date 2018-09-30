require "../spec_helper"

struct FormData::ArrayNilableSpec
  Params.mapping({
    foos: Array(Int32) | Nil,
    bars: Array(Int32)?,
  })

  describe self do
    it do
      params = self.new(form_data do |b|
        b.field("foos[]", "42")
        b.field("foos[]", "43")
        b.field("bars[]", "44")
      end)

      params.foos.should eq [42, 43]
      params.bars.should eq [44]
    end

    it "does not raise when foos is missing" do
      self.new(form_data do |b|
        b.field("bars[]", "44")
      end).foos.should be_nil
    end

    it "does not raise when bars is missing" do
      self.new(form_data do |b|
        b.field("foos[]", "42")
        b.field("foos[]", "43")
      end).bars.should be_nil
    end
  end
end
