# :nodoc:
struct Nil
  def self.from_string(value : String)
    raise TypeCastError.new unless value == "null"
  end

  def self.from_form_data_part(value : HTTP::FormData::Part)
    from_string(value.body.gets(value.size).not_nil!)
  end

  def self.new(pull : JSON::PullParser)
    raise TypeCastError.new # Any value read is considered non-Nil
  end
end
