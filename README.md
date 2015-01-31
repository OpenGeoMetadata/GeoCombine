# GeoCombine

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

### Clone all OpenGeoMetadata repositories

```sh
$ rake geocombine:clone
```

Will clone all edu.* OpenGeoMetadata repositories into `./tmp`

### Pull all OpenGeoMetadata repositories

```sh
$ rake geocombine:pull
```

Runs `git pull origin master` on all cloned repositories in `./tmp`

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
