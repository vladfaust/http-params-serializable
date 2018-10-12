# Special value meaning that a param is present but `Null`.
#
# In case of "query params" (resource params, HTTP query, form-data or form-urlencoded) an explicit
# `"null"` string is considered `Null`.
# When parsing a JSON body, `null` means `Null`, while no field at all means `Nil`.
#
# Note that:
#
# ```
# Null.new == Null # true
# ```
struct Null
  def initialize
  end

  def ==(klass : Null.class)
    true
  end

  def self.from_string(value : String)
    if value == "null"
      new
    else
      raise TypeCastError.new
    end
  end

  def self.from_form_data_part(value : HTTP::FormData::Part)
    from_string(value.body.gets(value.size).not_nil!)
  end

  def self.new(pull : JSON::PullParser)
    pull.read_null_or do
      raise TypeCastError.new
    end

    new
  end
end
