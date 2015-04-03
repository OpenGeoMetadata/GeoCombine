# GeoCombine

[![Build Status](https://travis-ci.org/OpenGeoMetadata/GeoCombine.svg?branch=master)](https://travis-ci.org/OpenGeoMetadata/GeoCombine) | [![Coverage Status](https://coveralls.io/repos/OpenGeoMetadata/GeoCombine/badge.svg?branch=master)](https://coveralls.io/r/OpenGeoMetadata/GeoCombine?branch=master)



A Ruby toolkit for managing geospatial metadata

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'geo_combine'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install geo_combine

## Usage
GeoCombine can be used as a set of rake tasks for cloning, updating, and indexing OpenGeoMetdata metdata. It can also be used as a Ruby library for converting metdata.

### Transforming metadata

```ruby
# Create a new ISO19139 object
> iso_metadata =  GeoCombine::Iso19139.new('./tmp/opengeometadata/edu.stanford.purl/bb/338/jh/0716/iso19139.xml')

# Convert it to GeoBlacklight
> iso_metadata.to_geoblacklight

# Convert that to JSON
> iso_metadata.to_geoblacklight.to_json

# Convert ISO or FGDC to HTML
> iso_metadata.to_html
```

### Clone all OpenGeoMetadata repositories

```sh
$ rake geocombine:clone
```

Will clone all edu.* OpenGeoMetadata repositories into `./tmp/opengeometadata`. Location of the OpenGeoMetadata repositories can be configured using the `OGM_PATH` environment variable.

```sh
$ OGM_PATH='my/custom/location' rake geocombine:clone
```

### Pull all OpenGeoMetadata repositories

```sh
$ rake geocombine:pull
```

Runs `git pull origin master` on all cloned repositories in `./tmp/opengeometadata` (or custom path with configured environment variable `OGM_PATH`)

### Index all of the GeoBlacklight documents

```sh
$ rake geocombine:index
```

Indexs all of the `geoblacklight.xml` files in cloned repositories to a Solr index running at http://127.0.0.1:8983/solr

## Contributing

1. Fork it ( https://github.com/[my-github-username]/GeoCombine/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
