# :nodoc:
struct Union(*T)
  def self.from_string(value : String)
    {% for type in T %}
      begin
        v = {{type}}.from_string(value)
        return v
      rescue TypeCastError
      end
    {% end %}

    raise TypeCastError.new
  end

  def self.from_form_data_part(value : HTTP::FormData::Part)
    from_string(value.body.gets(value.size).not_nil!)
  end
end
