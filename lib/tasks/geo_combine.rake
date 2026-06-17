# frozen_string_literal: true

require 'json'
require 'rsolr'
require 'find'
require 'faraday/net_http_persistent'
require 'geo_combine/harvester'
require 'geo_combine/indexer'
require 'geo_combine/geo_blacklight_harvester'

namespace :geocombine do
  desc 'Clone OpenGeoMetadata repositories'
  task :clone, [:repo] do |_t, args|
    ogm_path = ENV.fetch('OGM_PATH', 'tmp/opengeometadata')

    harvester = GeoCombine::Harvester.new(ogm_path: ogm_path)
    args[:repo] ? harvester.clone(args.repo) : harvester.clone_all
  end

  desc '"git pull" OpenGeoMetadata repositories'
  task :pull, [:repo] do |_t, args|
    ogm_path = ENV.fetch('OGM_PATH', 'tmp/opengeometadata')

    harvester = GeoCombine::Harvester.new(ogm_path: ogm_path)
    args[:repo] ? harvester.pull(args.repo) : harvester.pull_all
  end

  desc 'Index all JSON documents except Layers.json'
  task :index, [:ogm_path] => [:environment] do |_t, args|
    ogm_path = args.ogm_path || ENV.fetch('OGM_PATH', 'tmp/opengeometadata')

    indexer = GeoCombine::Indexer.new
    harvester = GeoCombine::Harvester.new(ogm_path: ogm_path)
    indexer.index(harvester.docs_to_index)
  end

  namespace :geoblacklight_harvester do
    desc 'Harvest documents from a configured GeoBlacklight instance'
    task :index, [:site] => [:environment] do |_t, args|
      raise ArgumentError, 'A site argument is required' unless args.site

      GeoCombine::GeoBlacklightHarvester.new(args.site.to_sym).index
    end
  end
end
