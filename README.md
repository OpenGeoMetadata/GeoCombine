# GeoCombine

[![Build Status](https://travis-ci.org/OpenGeoMetadata/GeoCombine.svg?branch=master)](https://travis-ci.org/OpenGeoMetadata/GeoCombine) | [![Coverage Status](https://coveralls.io/repos/OpenGeoMetadata/GeoCombine/badge.svg?branch=master)](https://coveralls.io/r/OpenGeoMetadata/GeoCombine?branch=master)


A Ruby toolkit for managing geospatial metadata, including:
- tasks for cloning, updating, and indexing OpenGeoMetdata metadata
- library for converting metadata between standards

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'geo_combine'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install geo_combine

## Usage

### Converting metadata

```ruby
# Create a new ISO19139 object
> iso_metadata =  GeoCombine::Iso19139.new('./tmp/opengeometadata/edu.stanford.purl/bb/338/jh/0716/iso19139.xml')

# Convert ISO to GeoBlacklight
> iso_metadata.to_geoblacklight

# Convert that to JSON
> iso_metadata.to_geoblacklight.to_json

# Convert ISO (or FGDC) to HTML
> iso_metadata.to_html
```

### OpenGeoMetadata

#### Clone OpenGeoMetadata repositories locally

```sh
$ bundle exec rake geocombine:clone
```

Will clone all `edu.*`,` org.*`, and `uk.*` OpenGeoMetadata repositories into `./tmp/opengeometadata`. Location of the OpenGeoMetadata repositories can be configured using the `OGM_PATH` environment variable.

```sh
$ OGM_PATH='my/custom/location' bundle exec rake geocombine:clone
```

You can also specify a single repository:

```sh
$ bundle exec rake geocombine:clone[edu.stanford.purl]
```

#### Update local OpenGeoMetadata repositories

```sh
$ bundle exec rake geocombine:pull
```

Runs `git pull origin master` on all cloned repositories in `./tmp/opengeometadata` (or custom path with configured environment variable `OGM_PATH`).

You can also specify a single repository:

```sh
$ bundle exec rake geocombine:pull[edu.stanford.purl]
```

#### Index GeoBlacklight documents

To index into Solr, GeoCombine requires a Solr instance that is running the
[GeoBlacklight schema](https://github.com/geoblacklight/geoblacklight):

```sh
$ bundle exec rake geocombine:index
```

Indexes the `geoblacklight.json` files in cloned repositories to a Solr index running at http://127.0.0.1:8983/solr

##### Custom Solr location

Solr location can also be specified by an environment variable `SOLR_URL`.

```sh
$ SOLR_URL=http://www.example.com:1234/solr/collection bundle exec rake geocombine:index
```

Depending on your Solr instance's performance characteristics, you may want to
change the [`commitWithin` parameter](https://lucene.apache.org/solr/guide/6_6/updatehandlers-in-solrconfig.html) (in milliseconds):

```sh
$ SOLR_COMMIT_WITHIN=100 bundle exec rake geocombine:index
```

## Tests

To run the tests, use:

```sh
$ bundle exec rake spec
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/GeoCombine/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
