module Params
  # Base class for all `Params` errors.
  class Error < Exception
  end

  # Base class for errors raised for particular params.
  abstract class ParamError < Error
    # Name of the param, e.g. `"id"`.
    getter name : String

    # Path to the param, e.g. `["user"]`.
    getter path : Array(String)? = nil

    # Print a full pretty path to the param.
    #
    # ```
    # error.pretty_path # => "id"
    # error.pretty_path # => "user[data][email]"
    # ```
    def pretty_path
      if path.nil?
        name
      else
        p = path.not_nil!

        if p.empty?
          name
        elsif p.size == 1
          "#{p[0]}[#{name}]"
        else
          p[0] + '[' + (p[1..-1].push(name)).join("][") + ']'
        end
      end
    end

    # :nodoc:
    def initialize(@name, @path = nil, @message = nil, @cause = nil)
      super(@message, @cause)
    end
  end

  # Raised when an incoming parameter cannot be casted to desired type.
  # For example, `"foo"` cannot be casted to `Int32`.
  class TypeCastError < ParamError
    # The original type of the incoming parameter.
    getter source : String

    # Desired type as defined in mapping.
    getter target : String

    # :nodoc:
    def initialize(value, @source : String, @target : String, @name : String, @path : Array(String)? = nil)
      super(@name, @path, "Couldn't cast value '#{value}' from #{@source} to #{@target} when parsing parameter '#{pretty_path}'")
    end
  end

  # Raised when a required parameter is not present in the request.
  class MissingError < ParamError
    # :nodoc:
    def initialize(@name : String, @path : Array(String)? = nil)
      super(@name, @path, "Parameter '#{pretty_path}' is missing")
    end
  end

  # Raised when request body is expected to be not nil, but nil instead.
  class EmptyBodyError < Error
    def initialize
      super("Request body can not be empty")
    end
  end

  # Raised when body size is too bog.
  class BodyTooBigError < Error
    # Limit in bytes.
    getter limit : UInt64

    # :nodoc:
    def initialize(@limit : UInt64)
      super("Request body is too big (at most #{limit} is expected)")
    end
  end

  # Raised when body requires "Content-Type" header but missing it.
  class MissingContentLengthError < Error
    # :nodoc:
    def initialize
      super("Content-Length header is missing")
    end
  end
end
