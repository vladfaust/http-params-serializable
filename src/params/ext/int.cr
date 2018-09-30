# :nodoc:
struct Int
  def self.from_string(value : String)
    {% for n in %w(8 16 32 64 128) %}
      {% if @type.name == "UInt" + n %}
        return value.to_u{{n.id}}
      {% elsif @type.name == "Int" + n %}
        return value.to_i{{n.id}}
      {% end %}
    {% end %}
  rescue ArgumentError
    raise TypeCastError.new
  end

  def self.from_form_data_part(value : HTTP::FormData::Part)
    from_string(value.body.gets(value.size).not_nil!)
  end
end
