# HTTP::Params::Serializable

[![Built with Crystal](https://img.shields.io/badge/built%20with-crystal-000000.svg?style=flat-square)](https://crystal-lang.org/)
[![Build status](https://img.shields.io/travis/com/vladfaust/http-params-serializable/master.svg?style=flat-square)](https://travis-ci.com/vladfaust/http-params-serializable)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg?style=flat-square)](https://github.vladfaust.com/http-params-serializable)
[![Releases](https://img.shields.io/github/release/vladfaust/http-params-serializable.svg?style=flat-square)](https://github.com/vladfaust/http-params-serializable/releases)
[![Awesome](https://github.com/vladfaust/awesome/blob/badge-flat-alternative/media/badge-flat-alternative.svg)](https://github.com/veelenga/awesome-crystal)
[![vladfaust.com](https://img.shields.io/badge/style-.com-lightgrey.svg?longCache=true&style=flat-square&label=vladfaust&colorB=0a83d8)](https://vladfaust.com)
[![Patrons count](https://img.shields.io/badge/dynamic/json.svg?label=patrons&url=https://www.patreon.com/api/user/11296360&query=$.included[0].attributes.patron_count&style=flat-square&colorB=red&maxAge=86400)](https://www.patreon.com/vladfaust)

The HTTP params parsing module for [Crysal](https://crystal-lang.org/).

## Supporters

Thanks to all my patrons, I can build and support beautiful Open Source Software! 🙏

[Lauri Jutila](https://github.com/ljuti)

[![Become Patron](https://vladfaust.com/img/patreon-small.svg)](https://www.patreon.com/vladfaust)

## About

This module is intended to provide a simple and convenient way to make an object to safely initialize from an HTTP params query (be it an URL query or `"application/x-www-form-urlencoded"` body). It tries to have an API almost the same as existing [`JSON::Serializable`](https://crystal-lang.org/api/0.27.0/JSON/Serializable.html) and [`YAML::Serializable`](https://crystal-lang.org/api/0.27.0/YAML/Serializable.html) modules, thus allowing to serialize infinitely-nested structures, including Arrays and Hashes.

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  http-params-serializable:
    github: vladfaust/http-params-serializable
    version: ~> 0.2.0
```

2. Run `shards install`

## Usage

Simple example:

```crystal
require "http-params-serializable"

# Don't use "Params" name for your params containers, because it currently causes a bug.
struct MyParams
  include HTTP::Params::Serializable
  getter id : Int32
end

params = MyParams.new("id=42")
pp params.id.class # => Int32

MyParams.new("")
# HTTP::Params::Serializable::ParamMissingError: Parameter "id" is missing

MyParams.new("id=foo")
# HTTP::Params::Serializable::ParamTypeCastError: Parameter "id" cannot be cast from "foo" to Int32
```

As you may expect, unions work as well:

```crystal
struct MyParams
  include HTTP::Params::Serializable
  getter id : Int32 | Nil
end

params = MyParams.new("id=")
pp params.id # => nil
```

Arrays are supported too:

```crystal
struct MyParams
  include HTTP::Params::Serializable
  getter foo : Array(Float32)
end

params = MyParams.new("foo[]=42.0&foo[]=43.5")
pp params.foo[1] # => 43.5
```

Nested params are supported:

```crystal
struct MyParams
  include HTTP::Params::Serializable
  getter nested : Nested

  struct Nested
    include HTTP::Params::Serializable
    getter foo : Bool
  end
end

params = MyParams.new("nested[foo]=true")
pp params.nested.foo # => true
```

Nested arrays are supported as well:

```crystal
struct MyParams
  include HTTP::Params::Serializable
  getter nested : Array(Nested)

  struct Nested
    include HTTP::Params::Serializable
    getter foo : Array(Int32)
  end
end

params = MyParams.new("nested[0][foo][]=1&nested[0][foo][]=2")
pp params.nested.first.foo.first # => [1, 2]
```

### Usage with [Kemal](http://kemalcr.com)

It's pretty easy to make your applications more safe:

```crystal
require "kemal"
require "http-params-serializable"

struct MyParams
  include HTTP::Params::Serializable
  getter id : Int32
end

get "/" do |env|
  if query = env.request.query
    query_params = MyParams.new(query)

    if query_params.id > 0
      "#{query_params.id} is positive\n"
    else
      "#{query_params.id} is negative or zero\n"
    end
  else
    "Empty query\n"
  end
rescue ex : HTTP::Params::Serializable::Error
  ex.message.not_nil! + "\n"
end

Kemal.run
```

```console
$ curl http://localhost:3000?id=42
42 is positive
$ curl http://localhost:3000?id=-1
-1 is negative or zero
$ curl http://localhost:3000?id=foo
Parameter "id" cannot be cast from "foo" to Int32
```

## Development

`crystal spec` and you're good to go.

## Contributing

1. Fork it (<https://github.com/vladfaust/http-params-serializable/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Vlad Faust](https://github.com/vladfaust) - creator and maintainer
