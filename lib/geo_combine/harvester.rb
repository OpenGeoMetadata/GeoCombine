# frozen_string_literal: true

require 'json'
require 'find'
require 'git'
require 'net/http'
require 'geo_combine/logger'

module GeoCombine
  # Harvests Geoblacklight documents from OpenGeoMetadata for indexing
  class Harvester
    attr_reader :ogm_path, :schema_version

    # GitHub API endpoint for OpenGeoMetadata repositories
    def self.ogm_api_uri
      URI('https://api.github.com/orgs/opengeometadata/repos?per_page=1000')
    end

    # Initialize a new harvester
    # @param ogm_path [String] path to the directory where repositories will be cloned
    # @param skip_repos [Array<String>] list of repository names to skip
    # @param schema_version [String] schema version to filter repositories by
    # @param logger [Logger] logger to use for logging messages
    def initialize(
      ogm_path:,
      skip_repos: ENV.fetch('OGM_SKIP_REPOS', '').split(',').map(&:strip),
      schema_version: ENV.fetch('SCHEMA_VERSION', 'Aardvark'),
      logger: GeoCombine::Logger.logger
    )
      @ogm_path = ogm_path
      @schema_version = schema_version
      @skip_repos = skip_repos
      @logger = logger
    end

    # Enumerable of docs to index, for passing to an indexer
    def docs_to_index
      return to_enum(:docs_to_index) unless block_given?

      @logger.info "loading documents from #{ogm_path}"
      Find.find(@ogm_path) do |path|
        # skip non-json and layers.json files
        if File.basename(path) == 'layers.json' || !File.basename(path).end_with?('.json')
          @logger.debug "skipping #{path}; not a geoblacklight JSON document"
          next
        end

        doc = JSON.parse(File.read(path))
        [doc].flatten.each do |record|
          record_schema = record['gbl_mdVersion_s'] || record['geoblacklight_version']
          record_id = record['layer_slug_s'] || record['dc_identifier_s']

          # skip indexing if no identifiable schema version
          unless record_schema
            @logger.debug "skipping #{record_id || path}; no schema version declared in record"
            next
          end

          # skip indexing if this record has a different schema version than what we want
          if record_schema != @schema_version
            @logger.debug "skipping #{record_id}; schema version #{record_schema} doesn't match #{@schema_version}"
            next
          end

          @logger.debug "found record #{record_id} at #{path}"
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
      @logger.info "updated #{repo}"
      repo
    end

    # Update all repositories
    # Return the names of repositories updated
    def pull_all
      updated = repositories.map(&method(:pull)).compact
      @logger.info "updated #{updated.size} repositories"
      updated
    end

    # Clone a repository via git
    # Return the name of the repository cloned, or nil if skipped
    def clone(repo)
      repo_path = File.join(@ogm_path, repo)
      repo_info = repository_info(repo)
      repo_url = "https://github.com/OpenGeoMetadata/#{repo}.git"
      repo_schemas = Array(repo_info.dig('custom_properties', 'supported_schemas'))

      # Skip if exists, archived, empty, or different schema
      return @logger.warn "skipping clone to #{repo_path}; directory exists" if File.directory? repo_path
      return @logger.warn "repository is archived: #{repo_url}" if repo_info['archived']
      return @logger.warn "repository is empty: #{repo_url}" if repo_info['size'].zero?
      unless repo_schemas.include? @schema_version
        return @logger.warn "repository #{repo_url} clone to #{repo_path}; repository properties don't include schema version #{@schema_version} (found #{repo_schemas.join(', ')})"
      end

      Git.clone(repo_url, nil, path: ogm_path, depth: 1)
      @logger.info "cloned #{repo_url} to #{repo_path}"
      repo
    end

    # Clone all repositories via git
    # Return the names of repositories cloned.
    def clone_all
      cloned = repositories.map(&method(:clone)).compact
      @logger.info "cloned #{cloned.size} repositories"
      cloned
    end

    private

    # List of repository names to harvest
    def repositories
      @repositories ||= JSON.parse(Net::HTTP.get(self.class.ogm_api_uri))
                            .filter { |repo| Array(repo.dig('custom_properties', 'supported_schemas')).include? @schema_version }
                            .filter { |repo| repo['size'].positive? }
                            .reject { |repo| repo['archived'] }
                            .reject { |repo| @skip_repos.include?(repo['name']) }
                            .map { |repo| repo['name'] }
    end

    # Fetch repository metadata from GitHub API
    def repository_info(repo_name)
      JSON.parse(Net::HTTP.get(URI("https://api.github.com/repos/opengeometadata/#{repo_name}")))
    end
  end
end
