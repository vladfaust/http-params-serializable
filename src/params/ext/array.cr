# :nodoc:
class Array(T)
  def self.from_strings(values : Array(String))
    case values
    when self
      values.unsafe_as(self)
    when Array(String)
      values.map do |e|
        T.from_string(e.as(String))
      end
    else
      raise TypeCastError.new
    end
  end

  def self.from_string(value : String)
    raise TypeCastError.new # Cannot cast a single String to an Array
  end

  def self.from_form_data_part(value : HTTP::FormData::Part)
    raise TypeCastError.new # Cannot cast a single Part to an Array
  end

  def self.from_form_data_parts(values : Array(HTTP::FormData::Part))
    values.map do |value|
      T.from_form_data_part(value)
    end
  end
end
