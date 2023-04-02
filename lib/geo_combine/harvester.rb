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
        'opengeometadata-rails',
        'gbl-1_to_aardvark'
      ]
    end

    # GitHub API endpoint for OpenGeoMetadata repositories
    def self.ogm_api_uri
      URI('https://api.github.com/orgs/opengeometadata/repos?per_page=1000')
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

    # Update a repository via git
    # If the repository doesn't exist, clone it.
    def pull(repo)
      repo_path = File.join(@ogm_path, repo)
      clone(repo) unless File.directory? repo_path

      Git.open(repo_path).pull
      puts "Updated #{repo}"
      1
    end

    # Update all repositories
    # Return the count of repositories updated
    def pull_all
      repositories.map(&method(:pull)).reduce(:+)
    end

    # Clone a repository via git
    # If the repository already exists, skip it.
    def clone(repo)
      repo_path = File.join(@ogm_path, repo)
      if File.directory? repo_path
        puts "Skipping clone to #{repo_path}; directory exists"
        return 0
      end

      repo_url = "https://github.com/OpenGeoMetadata/#{repo}.git"
      Git.clone(repo_url, nil, path: ogm_path, depth: 1)
      puts "Cloned #{repo_url}"
      1
    end

    # Clone all repositories via git
    # Return the count of repositories cloned.
    def clone_all
      repositories.map(&method(:clone)).reduce(:+)
    end

    private

    # List of repository names to harvest
    def repositories
      @repositories ||= JSON.parse(Net::HTTP.get(self.class.ogm_api_uri))
                            .filter { |repo| repo['size'].positive? }
                            .map { |repo| repo['name'] }
                            .reject { |name| self.class.denylist.include? name }
    end
  end
end
