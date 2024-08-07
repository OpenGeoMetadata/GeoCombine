# GeoCombine

![CI](https://github.com/OpenGeoMetadata/GeoCombine/actions/workflows/ruby.yml/badge.svg)
| [![Coverage Status](https://img.shields.io/badge/coverage-95%25-brightgreen)]()
| [![Gem Version](https://img.shields.io/gem/v/geo_combine.svg)](https://github.com/OpenGeoMetadata/GeoCombine/releases)

A Ruby toolkit for managing geospatial metadata, including:

- tasks for cloning, updating, and indexing OpenGeoMetadata metadata
- library for converting metadata between standards

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'geo_combine'
```

And then execute:

```sh
$ bundle install
```

Or install it yourself as:

```sh
$ gem install geo_combine
```

## Usage

### Converting metadata
#### Converting metadata into GeoBlacklight JSON
GeoCombine provides several classes representing different metadata standards that implement the `#to_geoblacklight` method for generating records in the [GeoBlacklight JSON format](https://opengeometadata.org/reference/):
```ruby
GeoCombine::Iso19139 # ISO 19139 XML
GeoCombine::OGP # OpenGeoPortal JSON
GeoCombine::Fgdc # FGDC XML
GeoCombine::EsriOpenData # Esri Open Data Portal JSON
GeoCombine::CkanMetadata # CKAN JSON
```
An example for converting an ISO 19139 XML record:
```ruby
# Create a new ISO19139 object
> iso_metadata =  GeoCombine::Iso19139.new('./tmp/opengeometadata/edu.stanford.purl/bb/338/jh/0716/iso19139.xml')

# Convert to GeoBlacklight's metadata format
> iso_metadata.to_geoblacklight

# Output it as JSON instead of a Ruby hash
> iso_metadata.to_geoblacklight.to_json
```
Some formats also support conversion into HTML for display in a web browser:
```ruby
# Create a new ISO19139 object
> iso_metadata =  GeoCombine::Iso19139.new('./tmp/opengeometadata/edu.stanford.purl/bb/338/jh/0716/iso19139.xml')

# Convert ISO to HTML
> iso_metadata.to_html
```

### Migrating metadata

You can use the `GeoCombine::Migrators` to migrate metadata from one schema to another.

Currently, the only migrator is `GeoCombine::Migrators::V1AardvarkMigrator` which migrates from the [GeoBlacklight v1 schema](https://github.com/OpenGeoMetadata/opengeometadata.github.io/blob/main/docs/gbl-1.0.md) to the [Aardvark schema](https://github.com/OpenGeoMetadata/opengeometadata.github.io/blob/main/docs/ogm-aardvark.md)

```ruby
# Load a record in geoblacklight v1 schema
record = JSON.parse(File.read('.spec/fixtures/docs/full_geoblacklight.json'))

# Migrate it to Aardvark schema
GeoCombine::Migrators::V1AardvarkMigrator.new(v1_hash: record).run
```

Some fields cannot be migrated automatically. To handle the migration of collection names to IDs when migrating from v1 to Aardvark, you can provide a mapping of collection names to IDs to the migrator:

```ruby
# You can store this mapping as a JSON or CSV file and load it into a hash
id_map = {
  'My Collection 1' => 'institution:my-collection-1',
  'My Collection 2' => 'institution:my-collection-2'
}

GeoCombine::Migrators::V1AardvarkMigrator.new(v1_hash: record, collection_id_map: id_map).run
```

### Downloading metadata from OpenGeoMetadata

#### Logging

Some of the tools and scripts in this gem use Ruby's `Logger` class to print information to `$stderr`. By default, the log level is set to `Logger::INFO`. For more verbose information, you can set the `LOG_LEVEL` environment variable to `DEBUG`:

```sh
$ LOG_LEVEL=DEBUG bundle exec rake geocombine:clone
```

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

_Note: If you are using zsh, you will need to use escape characters in front of the brackets:_

```sh
$ bundle exec rake geocombine:clone\[edu.stanford.purl\]
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

_Note: If you are using zsh, you will need to use escape characters in front of the brackets:_

```sh
$ bundle exec rake geocombine:pull\[edu.stanford.purl\]
```

#### Index GeoBlacklight documents

To index into Solr, GeoCombine requires a Solr instance that is running the
[GeoBlacklight schema](https://github.com/geoblacklight/geoblacklight):

```sh
$ bundle exec rake geocombine:index
```

If Blacklight is installed in the ruby environment and a solr index is configured, the rake task will use the solr index configured in the Blacklight application (this is the case when invoking GeoCombine from your GeoBlacklight installation). If Blacklight is unavailable, the rake task will try to find a Solr instance running at `http://localhost:8983/solr/blacklight-core`.

You can also set a the Solr instance URL using `SOLR_URL`:

```sh
$ SOLR_URL=http://www.example.com:1234/solr/collection bundle exec rake geocombine:index
```

By default, GeoCombine will index only records using the Aardvark metadata format. If you instead want to index records using an older format (e.g. because your GeoBlacklight instance is version 3 or older), you can set the `SCHEMA_VERSION` environment variable:

```sh
# Only index schema version 1.0 records
$ SCHEMA_VERSION=1.0 bundle exec rake geocombine:index
```

### Harvesting and indexing documents from GeoBlacklight sites

GeoCombine provides a Harvester class and rake task to harvest and index content from GeoBlacklight sites (or any site that follows the Blacklight API format). Given that the configurations can change from consumer to consumer and site to site, the class provides a relatively simple configuration API. This can be configured in an initializer, a wrapping rake task, or any other ruby context where the rake task our class would be invoked.

```sh
bundle exec rake geocombine:geoblacklight_harvester:index[YOUR_CONFIGURED_SITE_KEY]
```

#### Harvester configuration

Only the sites themselves are required to be configured but there are various configuration options that can (optionally) be supplied to modify the harvester's behavior.

```ruby
GeoCombine::GeoBlacklightHarvester.configure do
  {
    commit_within: '10000',
    crawl_delay: 1, # All sites
    debug: true,
    SITE1: {
      crawl_delay: 2, # SITE1 only
      host: 'https://geoblacklight.example.edu',
      params: {
        f: {
          dct_provenance_s: ['Institution']
        }
      }
    },
    SITE2: {
      host: 'https://geoportal.example.edu',
      params: {
        q: '*'
      }
    }
  }
end
```

##### Crawl Delays (default: none)

Crawl delays can be configured (in seconds) either globally for all sites or on a per-site basis. This will cause a delay for that number of seconds between each search results page (note that Blacklight 7 necessitates a lot of requests per results page and this only causes the delay per page of results)

##### Solr's commitWithin (default: 5000 milliseconds)

Solr's commitWithin option can be configured (in milliseconds) by passing a value under the commit_within key.

#### Transforming Documents

You may need to transform documents that are harvested for various purposes (removing fields, adding fields, omitting a document all together, etc). You can configure some ruby code (a proc) that will take the document in, transform it, and return the transformed document. By default the indexer will remove the `score`, `timestamp`, and `_version_` fields from the documents harvested. If you provide your own transformer, you'll likely want to remove these fields in addition to the other transformations you provide.

```ruby
GeoCombine::GeoBlacklightIndexer.document_transformer = -> (document) do
  # Removes "bogus_field" from the content we're harvesting
  # in addition to some other solr fields we don't want
  %w[_version_ score timestamp bogus_field].each do |field|
    document.delete(field)
  end

  document
end
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
