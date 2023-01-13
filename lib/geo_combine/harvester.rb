# frozen_string_literal: true

require 'json'
require 'find'
require 'git'

module GeoCombine
  # Harvests Geoblacklight documents from OpenGeoMetadata for indexing
  class Harvester
    attr_reader :ogm_path, :schema_version

    # Non-metadata repositories that shouldn't be harvested
    def self.denylist
      [
        'GeoCombine',
        'aardvark',
        'metadata-issues',
        'ogm_utils-python',
        'opengeometadata.github.io',
        'opengeometadata-rails'
      ]
    end

    # GitHub API endpoint for OpenGeoMetadata repositories
    def self.ogm_api_uri
      URI('https://api.github.com/orgs/opengeometadata/repos')
    end

    def initialize(
      ogm_path: ENV.fetch('OGM_PATH', 'tmp/opengeometadata'),
      schema_version: ENV.fetch('SCHEMA_VERSION', '1.0')
    )
      @ogm_path = ogm_path
      @schema_version = schema_version
    end

    # Enumerable of docs to index, for passing to an indexer
    def docs_to_index
      return to_enum(:docs_to_index) unless block_given?

      Find.find(@ogm_path) do |path|
        # skip non-json and layers.json files
        next unless File.basename(path).include?('.json') && File.basename(path) != 'layers.json'

        doc = JSON.parse(File.read(path))
        [doc].flatten.each do |record|
          # skip indexing if this record has a different schema version than what we want
          record_schema = record['gbl_mdVersion_s'] || record['geoblacklight_version']
          next unless record_schema == @schema_version

          yield record, path
        end
      end
    end

    # Update a repository via git, or all repositories if none specified.
    # If the repository doesn't exist, clone it. Return the count of repositories updated.
    def pull(repo = nil)
      return repositories.map(&method(:pull)).reduce(:+) unless repo

      repo_path = File.join(@ogm_path, repo)
      clone(repo) unless File.directory? repo_path

      Git.open(repo_path).pull && 1
    end

    # Clone a repository via git, or all repositories if none specified.
    # If the repository already exists, skip it. Return the count of repositories cloned.
    def clone(repo = nil)
      return repositories.map(&method(:clone)).reduce(:+) unless repo

      repo_path = File.join(@ogm_path, repo)
      return 0 if File.directory? repo_path

      repo_url = "https://github.com/OpenGeoMetadata/#{repo}.git"
      Git.clone(repo_url, repo, path: repo_path, depth: 1) && 1
    end

    private

    # List of repository names to harvest
    def repositories
      @repositories ||= JSON.parse(Net::HTTP.get(self.class.ogm_api_uri))
                            .map { |repo| repo['name'] if (repo['size']).positive? }
                            .reject { |repo| self.class.denylist.include? repo }
    end
  end
end
