# :nodoc:
class String
  def self.from_string(value : String)
    value
  end

  def self.from_form_data_part(value : HTTP::FormData::Part)
    from_string(value.body.gets(value.size).not_nil!)
  end
end
