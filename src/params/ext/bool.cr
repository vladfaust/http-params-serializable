# :nodoc:
struct Bool
  def self.from_string(value : String)
    case value
    when "true"  then true
    when "false" then false
    else              raise TypeCastError.new
    end
  end

  def self.from_form_data_part(value : HTTP::FormData::Part)
    from_string(value.body.gets(value.size).not_nil!)
  end
end
