# :nodoc:
struct Float
  def self.from_string(value : String)
    {% for n in %w(32 64) %}
      {% if @type.name == "Float" + n %}
        return value.to_f{{n.id}}
      {% end %}
    {% end %}
  rescue ArgumentError
    raise TypeCastError.new
  end

  def self.from_form_data_part(value : HTTP::FormData::Part)
    from_string(value.body.gets(value.size).not_nil!)
  end
end
