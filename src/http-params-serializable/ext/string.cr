@[HTTP::Params::Serializable::Scalar]
class String
  # Put `self` as an HTTP param into the *builder* at *key*.
  def to_http_param(builder : HTTP::Params::Builder, key : String)
    builder.add(key, to_http_param)
  end

  # Return `self` as an HTTP param string.
  def to_http_param
    self
  end

  # Parse `String` from an HTTP param (basically return itself).
  def self.new(http_param value : String)
    return value
  end
end
