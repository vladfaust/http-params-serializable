# Params

[![Built with Crystal](https://img.shields.io/badge/built%20with-crystal-000000.svg?style=flat-square)](https://crystal-lang.org/)
[![Build status](https://img.shields.io/travis/com/vladfaust/params.cr/master.svg?style=flat-square)](https://travis-ci.com/vladfaust/params.cr)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg?style=flat-square)](https://github.vladfaust.com/params.cr)
[![Releases](https://img.shields.io/github/release/vladfaust/params.cr.svg?style=flat-square)](https://github.com/vladfaust/params.cr/releases)
[![Awesome](https://github.com/vladfaust/awesome/blob/badge-flat-alternative/media/badge-flat-alternative.svg)](https://github.com/veelenga/awesome-crystal)
[![vladfaust.com](https://img.shields.io/badge/style-.com-lightgrey.svg?longCache=true&style=flat-square&label=vladfaust&colorB=0a83d8)](https://vladfaust.com)
[![Patrons count](https://img.shields.io/badge/dynamic/json.svg?label=patrons&url=https://www.patreon.com/api/user/11296360&query=$.included[0].attributes.patron_count&style=flat-square&colorB=red&maxAge=86400)](https://www.patreon.com/vladfaust)

The HTTP params parsing module for [Crysal](https://crystal-lang.org/).

[![Become Patron](https://vladfaust.com/img/patreon-small.svg)](https://www.patreon.com/vladfaust)

## About

This module adds `Params.mapping` method to the top-level namespace which turns an Object into a type-safe params container. An `initialize(HTTP::Request)` method will be added to it, which would parse params from these sources in this particular order, overwriting if needed:

* Resource params from `request.resource_params` or `.uri_params` or `.path_params` (should be set externally, e.g. by a router)
* HTTP query params (e.g. `"/?id=42"`)
* Body depending on `"Content-Type"` header, currently supporting `"application/x-www-form-urlencoded"`, `"multipart/form-data"` and `"application/json"`

The params object will have getters defined as in the mapping, e.g. `.id`.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  params:
    github: vladfaust/params.cr
    version: ~> 0.1.3
```

This shard follows [Semantic Versioning v2.0.0](http://semver.org/), so check [releases](https://github.com/vladfaust/prism/releases) and change the `version` accordingly.

## Usage

Call `Params.mapping` from within an object to turn it into a params container. The object would have got getters defined in accordance with the mapping, i.e. `id`, `name` and `additional_data` in the following example:

```crystal
require "params"

struct MyParams
  Params.mapping({
    id:   Int32,
    name: String?, # Nilable params

    # Nesting is supported
    # "under_score", "CamelCase", "lowerCamelCase" and "kebab-case"
    # are considered valid upon parsing, however, you should use "under_score"
    # casing in the mapping itself (i.e. in this code).
    #
    # Therefore, "additional_data", "AdditionalData", "additionalData" and "additional-data" is OK
    additional_data: {
      email: String,
      # This param can have explicit Null value
      # i.e. "null" string for query-like params
      # and `null` value for JSON.
      bio: Union(String | Nil | Null),
      tags: Array(String), # Arrays are supported too

      # Nesting is possible with ∞ levels
      deep: {
        random_numbers: Array(UInt64) | Nil, # Nilable arrays

        admin:   Bool,
        balance: Union(Float64 | Null), # Explicit `null` differs from `nil`
      } | Nil, # Nilable nesting
    },
  })
end

params = MyParams.new(context.request) # Initialize it with a HTTP::Request,
                                       # this would trigger the parsing

params.id                    # => 42
params.name                  # => "John"
params.additional_data.email # => user@example.com
```

The following is an example of a valid HTTP query for this params object, formatted for convenience. You may note that keys are case-insensitive. This structure also applies for `"application/x-www-form-urlencoded"` and `"multipart/form-data"` content types:

```
https://example.com/path?id=42
&name=Jake
&additionalData[email]=foo@example.com
&AdditionalData[bio]=foo
&additional_data[tags][]=a
&additional-data[tags]=b
&additionalData[deep][randomNumbers][]=1
&AdditionalData[deep][RandomNumbers][]=2
&additional_data[deep][admin]=true
&additional-data[deep][balance]=42000.42
```

An example of a valid JSON body would be:

```json
{
  "id": 42,
  "name": "John",
  "additionalData": {
    "email": "foo@example.com",
    "bio": "foo",
    "tags": ["foo", "bar"],
    "deep": {
      "randomNumbers": [1, 2],
      "admin": true,
      "balance": null
    }
  }
}
```

Parsing may eventually raise `Params::TypeCastError` if an incoming parameter cannot be casted into desired type, or `Params::MissingError` when a required (i.e. non-nilable) parameter is missing. There is a bunch of other possible errors, see the [docs](https://github.vladfaust.com/params.cr).

## Development

`crystal spec` and you're good to go.

## Contributing

1. Fork it (<https://github.com/vladfaust/params.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [@vladfaust](https://github.com/vladfaust) Vlad Faust - creator, maintainer
