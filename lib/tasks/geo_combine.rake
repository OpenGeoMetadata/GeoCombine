# frozen_string_literal: true

require 'geo_combine/harvester'
require 'geo_combine/indexer'

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
end
