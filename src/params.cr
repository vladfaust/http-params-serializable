require "http/request"
require "http/formdata"
require "http/multipart"
require "json"

require "./params/ext/**"
require "./params/*"

module Params
  # 8 MB ought to be enough for anybody.
  DEFAULT_MAX_BODY_SIZE = UInt64.new(8 * 1024 ** 2)

  # Copy *from* `IO` at most *limit* bytes.
  def self.copy_io(from : IO, limit) : IO
    to = IO::Memory.new

    IO.copy(from, to, limit)
    IO.copy(to, from)

    from.rewind
    to.rewind

    return to
  end

  # Define parameters mapping.
  #
  # ### Example
  #
  # ```
  # require "params"
  #
  # struct MyParams
  #   Params.mapping({
  #     id:   Int32,
  #     name: String?, # Nilable params
  #
  #     # Nesting is supported
  #     extra: {
  #       # "under_score", "CamelCase", "lowerCamelCase" and "kebab-case"
  #       # are considered valid upon parsing, however, you should use "under_score"
  #       # casing in the mapping itself (i.e. in this code).
  #       #
  #       # So, "the_email", "TheEmail", "theEmail" and "the-email" is expected for this param
  #       the_email: String,
  #       bio:       String | Nil,  # Alternative syntax for nilable params
  #       tags:      Array(String), # Arrays are supported too
  #
  #       # Nesting is possible with ∞ levels
  #       deep: {
  #         random_numbers: Array(UInt64) | Nil, # Nilable arrays
  #
  #         admin:   Bool,
  #         balance: Float64,
  #       } | Nil, # Nilable nesting
  #     },
  #   })
  # end
  #
  # params = MyParams.new(context.request)
  # params.id              # => 42
  # params.name            # => "John"
  # params.extra.the_email # => foo@example.com
  # ```
  #
  # Getters are defined as well according to the mapping, e.g. `.id`, `.name` and `.extra` in this example.
  #
  # ### Initializer
  #
  # This macro defines an initializer accepting `HTTP::Request` argument,
  # which parses parameters from multiple sources (latter overwrites):
  #
  # * Resource params - a `Hash(String, String)` object retreived by either
  # `request.resource_params`, `request.uri_params` or `request.path_params` method call,
  # if defined. Note that neither array nor nested params are supported in this case.
  #
  # * *HTTP query*, e.g. `"/?id=42&user[name]=foo&user[tags][]=bar&user[tags][]=baz"`.
  # Note that the same object and array structure is applied for
  # `"application/x-www-form-urlencoded"` and `"multipart/form-data"`.
  #
  # * *Body* depending on `"Content-Type"` header, currently supporting
  # `"application/x-www-form-urlencoded"`, `"multipart/form-data"` and `"application/json"` types.
  #
  # The initializer also accepts *limit* argument which defines the maximum amount of bytes
  # to be read from the request body. Raises `Params::BodyTooBigError` otherwise.
  # Defaults to `DEFAULT_MAX_BODY_SIZE`.
  #
  # Another argument is *preserve_body* (defaults to `false`).
  # If set to `true`, the request will remain its original body after reading from it.
  #
  # Summing it up, the following initializer would be defined on `MyParams`:
  #
  # ```
  # def initialize(request : HTTP::Request, limit = Params::DEFAULT_MAX_BODY_SIZE, preserve_body = false)
  # ```
  #
  # ### Other errors
  #
  # Parsing may eventually raise `Params::TypeCastError` if an incoming parameter cannot be casted into desired type, or `Params::MissingError` when a required (i.e. non-nilable) parameter is missing. Also see `Params::MissingContentLengthError` and `Params::EmptyBodyError`.
  #
  # ### Tips and tricks
  #
  # * An `Array` will contain values both from the HTTP query and `"application/x-www-form-urlencoded"` data.
  # * Define a `.from_string(String)`, `#initialize(JSON::PullParser)`
  # and `.from_form_data_part(HTTP::FormData::Part)` methods to make a custom type readable from params.
  # * You can read files from `HTTP::FormData::Part`.
  macro mapping(params, inner = false)
    macro finished
      {%
        params = params.map do |key, value|
          type = nil
          nilable = false
          nested = false

          if value.is_a?(Call)
            if value.name.stringify == "|" &&
               value.args.size == 1 &&
               value.args[0].resolve == Nil
              nilable = true

              if (receiver = value.receiver).is_a?(NamedTupleLiteral)
                nested = true
                type = receiver
              elsif receiver.is_a?(Generic)
                if (node = receiver.resolve).union?
                  raise "Complex union params with pipe syntax aren't supported. Use explicit `Union(TypeA, TypeB)` syntax instead. Given `#{value}`"
                else
                  type = node
                end
              elsif receiver.is_a?(Call)
                raise "`Call | Nil` params definition syntax is not supported. Use explicit `Union(TypeA, TypeB)` syntax instead. Given `#{value}`"
              elsif receiver.is_a?(Path)
                type = receiver.resolve
              else
                raise "Bug: unhandled receiver type `#{receiver}`"
              end
            else
              if value.name.stringify == "|" &&
                 value.args.size == 1 &&
                 value.args[0].resolve == Null
                raise "Pipe union with Null syntax is not supported. Use explicit `Union(Type, Null)` syntax instead. Given `#{value}`"
              else
                raise "Bug: unhandled param definition scenario: `#{value}`"
              end
            end
          elsif value.is_a?(Generic)
            if (union = value.resolve).union?
              if union.union_types.any? { |t| t < Enumerable }
                if union.nilable? && union.union_types.size == 2
                  nilable = true
                  type = union.union_types.find { |t| t != Nil }
                else
                  raise "Cannot define a param with Enumerable within a Union. Given: `#{value.resolve}`"
                end
              else
                # I.e. `Union(Int32 | Nil)`
                if value.resolve.nilable?
                  nilable = true
                end

                type = value.resolve
              end
            else
              # I.e. `Array(String)`
              type = value.resolve
            end
          elsif value.is_a?(Path)
            type = value.resolve
          elsif value.is_a?(NamedTupleLiteral)
            type = value
            nested = true
          else
            raise "Bug: unhandled value `#{value}`"
          end

          {key, {
            defined_type: value,
            type:         type,
            nilable:      nilable,
            nested:       nested,
          }}
        end.reduce({} of String => Object) do |hash, (key, value)|
          hash[key.stringify] = value
          hash
        end
      %}

      {% for key, value in params %}
        {% if value["nested"] %}
          class {{key.camelcase.id}}
            ::Params.mapping({{value["type"]}}, true)
          end

          getter {{key.id}} : {{key.camelcase.id}}{{" | Nil = nil".id if value["nilable"]}}
        {% else %}
          getter {{key.id}} : {{value["type"]}}{{" | Nil = nil".id if value["nilable"]}}

          {% if value["type"] < Enumerable %}
            @{{key.id}}_http_query_values : Array(String) | Nil = nil
            @{{key.id}}_form_data_parts : Array(HTTP::FormData::Part) | Nil = nil
          {% end %}
        {% end %}
      {% end %}

      @initialized = Hash(String, Bool).new
      @path : Array(String) | Nil = nil

      protected def ensure_params!
        {% for key, value in params %}
          {% if !value["nested"] && value["type"] < Enumerable %}
            if @{{key.id}}_http_query_values
              @{{key.id}} = {{value["type"]}}.from_strings(@{{key.id}}_http_query_values.not_nil!)
              @initialized[{{key}}] = true
            end

            if @{{key.id}}_form_data_parts
              @{{key.id}} = {{value["type"]}}.from_form_data_parts(@{{key.id}}_form_data_parts.not_nil!)
              @initialized[{{key}}] = true
            end
          {% end %}

          raise ::Params::MissingError.new({{key}}, @path) unless @initialized.has_key?({{key}})

          {% if value["nested"] %}
            @{{key.id}}.try &.ensure_params!
          {% end %}
        {% end %}
      end

      protected def parse_resource_param(key, value)
        if value.empty?
          return
        end

        case key
        {% for key, value in params %}
          {% keys = [key, key.camelcase, key.underscore, key.underscore.gsub(/_/, "-"), key.camelcase[0...1].downcase + key.camelcase[1..-1]].uniq %}
          {% unless value["nested"] %}
          when {{keys.map(&.stringify).join(", ").id}}
            begin
              @{{key.id}} = {{value["type"]}}.from_string(value)
              @initialized[{{key}}] = true
            rescue ::TypeCastError
              raise ::Params::TypeCastError.new(value, value.class.name, {{value["defined_type"].stringify}}, {{key}}, @path)
            end
          {% end %}
        {% end %}
        end
      end

      {% for what, i in %w(http_query_param form_data_part) %}
        protected def parse_{{what.id}}(key : String, value : {{i == 0 ? String : HTTP::FormData::Part}})
          if {{i == 0 ? "value.empty?".id : "value.body.as(IO::Memory).size == 0".id}}
            return
          end

          case key
          {% for key, value in params %}
            {% keys = [key, key.camelcase, key.underscore, key.underscore.gsub(/_/, "-"), key.camelcase[0...1].downcase + key.camelcase[1..-1]].uniq %}
            {% if value["nested"] %}
              when {{keys.map { |k| "/^#{k.id}\\]?\\[(.+)/" }.join(", ").id}}
                {% if value["nilable"] %}
                  @{{key.id}} ||= {{key.camelcase.id}}.new(@path ? @path.not_nil!.dup.push({{key}}) : [{{key}}])
                {% else %}
                  unless @initialized.has_key?({{key}})
                    @{{key.id}} = {{key.camelcase.id}}.new(@path ? @path.not_nil!.dup.push({{key}}) : [{{key}}])
                    @initialized[{{key}}] = true
                  end
                {% end %}

                @{{key.id}}.not_nil!.parse_{{what.id}}($~[1], value)
            {% else %}
              {% if value["type"] < Enumerable %}
                when {{keys.map { |k| (k + "[]").stringify }.join(", ").id}}, {{keys.map { |k| (k + "][]").stringify }.join(", ").id}}
                  {% if i == 0 %}
                    unless @{{key.id}}_http_query_values
                      @{{key.id}}_http_query_values = [] of String
                    end

                    @{{key.id}}_http_query_values.not_nil! << value
                  {% else %}
                    unless @{{key.id}}_form_data_parts
                      @{{key.id}}_form_data_parts = [] of HTTP::FormData::Part
                    end

                    @{{key.id}}_form_data_parts.not_nil! << value
                  {% end %}
              {% else %}
                when {{keys.map(&.stringify).join(", ").id}}, {{keys.map { |k| (k + "]").stringify }.join(", ").id}}
                  begin
                    @{{key.id}} = {{value["type"]}}.from_{{i == 0 ? "string".id : "form_data_part".id}}(value)
                    @initialized[{{key}}] = true
                  rescue ::TypeCastError
                    raise ::Params::TypeCastError.new(value, value.class.name, {{value["defined_type"].stringify}}, {{key}}, @path)
                  end
              {% end %}
            {% end %}
          {% end %}
          end
        end
      {% end %}

      protected def parse_json_body(pull : JSON::PullParser)
        location = pull.location

        pull.read_begin_object
        while pull.kind != :end_object
          key = pull.read_object_key

          case key
            {% for key, value in params %}
              {% keys = [key, key.camelcase, key.underscore, key.underscore.gsub(/_/, "-"), key.camelcase[0...1].downcase + key.camelcase[1..-1]].uniq %}
              when {{keys.map(&.stringify).join(", ").id}}
                {% if value["nested"] %}
                  {% if value["nilable"] %}
                    @{{key.id}} ||= {{key.camelcase.id}}.new(@path ? @path.not_nil!.dup.push({{key}}) : [{{key}}])
                    @{{key.id}}.not_nil!.parse_json_body(pull)
                  {% else %}
                    unless @initialized.has_key?({{key}})
                      begin
                        @{{key.id}} = {{key.camelcase.id}}.new(@path ? @path.not_nil!.dup.push({{key}}) : [{{key}}])
                        @{{key.id}}.parse_json_body(pull)
                        @initialized[{{key}}] = true
                      rescue JSON::ParseException
                      end
                    end
                  {% end %}
                {% else %}
                  begin
                    # `Union(Type | Null | Nil)` will return `Nil` on `null`,
                    # that's not what we want. We want `Null` instead.
                    {% if value["type"].union? && value["type"].union_types.includes?(Null) %}
                      value = {{value["type"]}}.new(pull)

                      if value.nil?
                        @{{key.id}} = Null.new
                      else
                        @{{key.id}} = value
                      end
                    {% else %}
                      @{{key.id}} = {{value["type"]}}.new(pull)
                    {% end %}

                    @initialized[{{key}}] = true
                  rescue ex : JSON::ParseException
                    value = pull.read_raw
                    raise ::Params::TypeCastError.new(value, value.class.name, {{value["defined_type"].stringify}}, {{key}}, @path)
                  end
                {% end %}
            {% end %}
          end
        end

        pull.read_next
      end

      {% begin %}
        {% if inner %}
          protected def initialize(@path : Array(String))
        {% else %}
          def initialize(
            request : HTTP::Request,
            limit = ::Params::DEFAULT_MAX_BODY_SIZE,
            preserve_body = false,
          )
        {% end %}
          {% for key, value in params %}
            {% if value["nilable"] %}
              @{{key.id}} = nil
              @initialized[{{key}}] = true
            {% else %}
              {% if value["nested"] %}
                @{{key.id}} = uninitialized {{key.camelcase.id}}
              {% else %}
                @{{key.id}} = uninitialized {{value["type"]}}
              {% end %}
            {% end %}
          {% end %}

          {% unless inner %}
            {% for m in %i(request_params uri_params path_params) %}
              if request.responds_to?({{m}}) && request.{{m.id}}
                request.{{m.id}}.not_nil!.each do |key, value|
                  parse_resource_param(key, value)
                end
              end
            {% end %}

            request.query_params.each do |key, value|
              parse_http_query_param(key, value)
            end

            case request.headers["Content-Type"]?
            when /^application\/x-www-form-urlencoded/
              raise ::Params::EmptyBodyError.new if request.body.nil?
              raise ::Params::MissingContentLengthError.new unless request.content_length
              raise ::Params::BodyTooBigError.new(limit) if request.content_length.not_nil! > limit

              body = ::Params.copy_io(request.body.not_nil!, limit) if preserve_body

              HTTP::Params.parse(request.body.not_nil!.gets(limit).not_nil!).each do |key, value|
                parse_http_query_param(key, value)
              end

              request.body = body if preserve_body
            when /^multipart\/form-data/
              raise ::Params::EmptyBodyError.new if request.body.nil?
              raise ::Params::MissingContentLengthError.new unless request.content_length
              raise ::Params::BodyTooBigError.new(limit) if request.content_length.not_nil! > limit

              body = ::Params.copy_io(request.body.not_nil!, limit) if preserve_body

              HTTP::FormData.parse(request) do |part|
                io = part.size ? IO::Memory.new(part.size.not_nil!) : IO::Memory.new
                IO.copy(part.body, io)
                io.rewind
                part.body = io
                parse_form_data_part(part.name, part)
              end

              request.body = body if preserve_body
            when /^application\/json/
              raise ::Params::EmptyBodyError.new if request.body.nil?
              raise ::Params::MissingContentLengthError.new unless request.content_length
              raise ::Params::BodyTooBigError.new(limit) if request.content_length.not_nil! > limit

              body = ::Params.copy_io(request.body.not_nil!, limit) if preserve_body

              begin
                parse_json_body(JSON::PullParser.new(request.body.not_nil!))
              rescue JSON::ParseException
              end

              request.body = body if preserve_body
            end

            ensure_params!
          {% end %}
        end
      {% end %}
    end
  end
end
