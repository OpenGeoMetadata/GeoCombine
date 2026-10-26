# frozen_string_literal: true

require 'json'
require 'find'
require 'git'
require 'net/http'
require 'set'
require 'geo_combine/logger'
require 'geo_combine/schema'

module GeoCombine
  # Harvests Geoblacklight documents from OpenGeoMetadata for indexing
  class Harvester
    # Files at the root of a repository that describe the repository, not records
    REPOSITORY_FILES = %w[layers.json withdrawn.json].freeze

    attr_reader :ogm_path, :schema_version, :present_ids

    # GitHub API endpoint for OpenGeoMetadata repositories
    def self.ogm_api_uri
      URI('https://api.github.com/orgs/opengeometadata/repos?per_page=1000')
    end

    # Initialize a new harvester
    # @param ogm_path [String] path to the directory where repositories will be cloned
    # @param skip_repos [Array<String>] list of repository names to skip
    # @param skip_restricted [Boolean] whether to skip indexing restricted documents
    # @param schema_version [String] schema version to filter repositories by
    # @param logger [Logger] logger to use for logging messages
    def initialize(
      ogm_path:,
      skip_repos: ENV.fetch('OGM_SKIP_REPOS', '').split(',').map(&:strip),
      skip_restricted: ENV.fetch('OGM_SKIP_RESTRICTED', 'true') == 'true',
      schema_version: ENV.fetch('SCHEMA_VERSION', GeoCombine::Schema::DEFAULT_VERSION),
      logger: GeoCombine::Logger.logger
    )
      @ogm_path = ogm_path
      @schema_version = schema_version
      @skip_repos = skip_repos
      @skip_restricted = skip_restricted
      @logger = logger
    end

    # Enumerable of docs to index, for passing to an indexer
    # While enumerating, collects the ids of the records yielded in present_ids
    def docs_to_index
      return to_enum(:docs_to_index) unless block_given?

      @present_ids = Set.new
      @walk_complete = false
      @logger.info "loading documents from #{ogm_path}"
      Find.find(@ogm_path) do |path|
        # skip hidden directories, like .git
        Find.prune if hidden_directory?(path)

        # skip non-json files, and files that describe a repository rather than records
        if REPOSITORY_FILES.include?(File.basename(path)) || !File.basename(path).end_with?('.json')
          @logger.debug "skipping #{path}; not a geoblacklight JSON document"
          next
        end

        records_in(path).each do |record|
          next unless record.is_a?(Hash)

          record_id = GeoCombine::Schema.id(record)
          next unless indexable?(record, record_id, path)

          @logger.debug "found record #{record_id} at #{path}"
          @present_ids << record_id
          yield record, path
        end
      end
      @walk_complete = true
    end

    # Whether the run visited every file
    def walk_complete?
      @walk_complete == true
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

    # Whether to index a record; if not, log why
    def indexable?(record, record_id, path)
      record_schema = GeoCombine::Schema.version(record)
      record_rights = record['dct_accessRights_s'] || record['dc_rights_s']

      # skip indexing if no identifiable schema version
      unless record_schema
        @logger.debug "skipping #{path}; no schema version declared in record"
        return false
      end

      # skip indexing if this record has a different schema version than what we want
      if record_schema != @schema_version
        @logger.debug "skipping #{record_id}; schema version #{record_schema} doesn't match #{@schema_version}"
        return false
      end

      # skip indexing if this record is restricted and we want to skip restricted records
      if @skip_restricted && record_rights == 'Restricted'
        @logger.debug "skipping #{record_id}; access rights are restricted"
        return false
      end

      true
    end

    # Whether a path is a hidden directory inside ogm_path
    def hidden_directory?(path)
      path != @ogm_path && File.basename(path).start_with?('.') && File.directory?(path)
    end

    # The records in a JSON file. A file that can't be parsed is logged and skipped,
    # so one bad file can't stop the rest of the walk.
    def records_in(path)
      json = File.read(path, mode: 'r:bom|utf-8')
      raise JSON::ParserError, 'not valid UTF-8' unless json.valid_encoding?

      [JSON.parse(json)].flatten
    rescue JSON::ParserError => e
      @logger.error "skipping #{path}; could not parse JSON: #{e.message}"
      []
    end

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
