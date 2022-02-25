# frozen_string_literal: true

require 'net/http'
require 'json'
require 'rsolr'
require 'find'
require 'geo_combine/geo_blacklight_harvester'

namespace :geocombine do
  desc 'Clone OpenGeoMetadata repositories'
  task :clone, [:repo] do |_t, args|
    if args.repo
      ogm_repos = ["https://github.com/OpenGeoMetadata/#{args.repo}.git"]
    else
      ogm_api_uri = URI('https://api.github.com/orgs/opengeometadata/repos')
      ogm_repos = JSON.parse(Net::HTTP.get(ogm_api_uri)).map do |repo|
        repo['clone_url'] if (repo['size']).positive?
      end.compact
      ogm_repos.reject! { |repo| GeoCombineRake.denylist.include?(repo) }
    end
    ogm_repos.each do |repo|
      Kernel.system "echo #{repo} && mkdir -p #{GeoCombineRake.ogm_path} && cd #{GeoCombineRake.ogm_path} && git clone --depth 1 #{repo}"
    end
  end

  desc '"git pull" OpenGeoMetadata repositories'
  task :pull, [:repo] do |_t, args|
    paths = if args.repo
              [File.join(GeoCombineRake.ogm_path, args.repo)]
            else
              Dir.glob("#{GeoCombineRake.ogm_path}/*")
            end
    paths.each do |path|
      next unless File.directory?(path)

      Kernel.system "echo #{path} && cd #{path} && git pull origin"
    end
  end

  desc 'Index all JSON documents except Layers.json'
  task :index do
    puts "Indexing #{GeoCombineRake.ogm_path} into #{GeoCombineRake.solr_url}"
    solr = RSolr.connect url: GeoCombineRake.solr_url, adapter: :net_http_persistent
    Find.find(GeoCombineRake.ogm_path) do |path|
      next unless File.basename(path).include?('.json') && File.basename(path) != 'layers.json'

      doc = JSON.parse(File.read(path))
      [doc].flatten.each do |record|
        puts "Indexing #{record['layer_slug_s']}: #{path}" if $DEBUG
        solr.update params: { commitWithin: GeoCombineRake.commit_within, overwrite: true },
                    data: [record].to_json,
                    headers: { 'Content-Type' => 'application/json' }
      rescue RSolr::Error::Http => e
        puts e
      end
    end
    solr.commit
  end

  namespace :geoblacklight_harvester do
    desc 'Harvest documents from a configured GeoBlacklight instance'
    task :index, [:site] => [:environment] do |_t, args|
      raise ArgumentError, 'A site argument is required' unless args.site

      GeoCombine::GeoBlacklightHarvester.new(args.site.to_sym).index
    end
  end
end

# Class to hold helper methods for use in GeoCombine rake tasks
class GeoCombineRake
  def self.commit_within
    (ENV['SOLR_COMMIT_WITHIN'] || 5000).to_i
  end

  def self.denylist
    [
      'https://github.com/OpenGeoMetadata/GeoCombine.git',
      'https://github.com/OpenGeoMetadata/aardvark.git',
      'https://github.com/OpenGeoMetadata/metadata-issues.git',
      'https://github.com/OpenGeoMetadata/ogm_utils-python.git',
      'https://github.com/OpenGeoMetadata/opengeometadata.github.io.git',
      'https://github.com/OpenGeoMetadata/opengeometadata-rails.git'
    ]
  end

  def self.ogm_path
    ENV['OGM_PATH'] || 'tmp/opengeometadata'
  end

  def self.solr_url
    ENV['SOLR_URL'] || 'http://127.0.0.1:8983/solr/blacklight-core'
  end
end
