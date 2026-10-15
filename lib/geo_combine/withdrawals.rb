# frozen_string_literal: true

require 'json'
require 'geo_combine/logger'
require 'geo_combine/schema'

module GeoCombine
  # Reads the withdrawal logs (withdrawn.json) that OpenGeoMetadata repositories publish at
  # their root, and deletes the records they list from an index.
  #
  # A record is deleted only when a log lists it. Removing a record's file is not a
  # withdrawal, and an id still published by any record in the harvest is never deleted.
  class Withdrawals
    FILENAME = 'withdrawn.json'

    # The reasons the convention defines; consumers treat any other value as 'other'
    REASONS = %w[superseded duplicate upstream-removed rights privacy quality out-of-scope other].freeze

    # W3C-DTF: a year, year and month, date, or date and time with a time zone
    DATE_FORMAT = /\A\d{4}(-\d{2}(-\d{2}(T\d{2}:\d{2}(:\d{2}(\.\d+)?)?(Z|[+-]\d{2}:\d{2}))?)?)?\z/

    Entry = Struct.new(:id, :date, :reason, :source_path, keyword_init: true)

    # Raised internally when a log doesn't match the schema
    class InvalidLog < StandardError; end

    attr_reader :ogm_path

    # Initialize a new reader of withdrawal logs
    # @param ogm_path [String] path to the directory where repositories are cloned
    # @param skip_repos [Array<String>] list of repository names whose logs are ignored
    # @param logger [Logger] logger to use for logging messages
    def initialize(
      ogm_path:,
      skip_repos: ENV.fetch('OGM_SKIP_REPOS', '').split(',').map(&:strip),
      logger: GeoCombine::Logger.logger
    )
      @ogm_path = ogm_path
      @skip_repos = skip_repos
      @logger = logger
    end

    # Paths of the logs to read: one at the root of each repository, plus one at the root
    # of ogm_path itself, for when it is a single repository. A repository that isn't being
    # harvested doesn't get to delete from the index.
    def paths
      repo_logs = Dir.glob(File.join('*', FILENAME), base: ogm_path).sort
                     .reject { |path| @skip_repos.include?(File.dirname(path)) }
      [FILENAME, *repo_logs].map { |path| File.join(ogm_path, path) }.select { |path| File.file?(path) }
    end

    # Withdrawn entries keyed by id; when an id is listed more than once, the last entry wins
    def entries
      @entries ||= paths.each_with_object({}) do |path, entries|
        read(path).each { |entry| entries[entry.id] = entry }
      end
    end

    # Delete withdrawn records from the index. The harvester must have walked every record
    # first, so it knows which ids are still published: those are never deleted.
    # Every run deletes every withdrawn id again; Solr ignores a delete for an id it doesn't have.
    # Returns the ids deleted.
    def apply(harvester:, indexer:)
      unless harvester.walk_complete?
        @logger.error 'not deleting withdrawn records; the harvest did not walk every record'
        return []
      end

      present, absent = entries.keys.partition { |id| harvester.present_ids.include?(id) }
      warn_still_published(present)
      deleted = absent.empty? ? [] : indexer.delete(absent)

      @logger.info "withdrawals: #{entries.size} entries, #{present.size} still published, " \
                   "#{deleted.size} deleted or already absent"
      deleted
    end

    private

    # A repository that withdraws a record it still publishes contradicts itself; presence wins
    def warn_still_published(ids)
      ids.each do |id|
        @logger.warn "not deleting #{id}; it is withdrawn in #{entries[id].source_path} but still published"
      end
    end

    # The valid entries in a log. A log that can't be read is logged and skipped, so one
    # bad log can't stop the others, or indexing.
    def read(path)
      json = File.read(path, mode: 'r:bom|utf-8')
      raise JSON::ParserError, 'not valid UTF-8' unless json.valid_encoding?

      log = JSON.parse(json)
      validate(log)
      log['withdrawn'].each_with_index.filter_map { |entry, index| entry_from(entry, path, index) }
    rescue InvalidLog, JSON::ParserError, SystemCallError => e
      @logger.error "skipping withdrawal log #{path}: #{e.message}"
      []
    end

    def validate(log)
      raise InvalidLog, 'not a JSON object with a "withdrawn" array' unless log.is_a?(Hash) && log['withdrawn'].is_a?(Array)

      version = log.fetch('ogm_version', '1.0').to_s
      raise InvalidLog, "unsupported ogm_version #{version}" unless version.split('.').first == '1'
    end

    # An entry, or nil if it has no usable id or date
    def entry_from(entry, path, index)
      return invalid(path, index, 'not a JSON object') unless entry.is_a?(Hash)

      id, date, reason = entry.values_at('id', 'date', 'reason')
      return invalid(path, index, "unusable id #{id.inspect}") unless GeoCombine::Schema.valid_id?(id)
      return invalid(path, index, "invalid date #{date.inspect} for #{id}") unless date.is_a?(String) && date.match?(DATE_FORMAT)

      reason = 'other' unless reason.nil? || REASONS.include?(reason)
      Entry.new(id:, date:, reason:, source_path: path)
    end

    def invalid(path, index, problem)
      @logger.error "skipping entry #{index} in withdrawal log #{path}: #{problem}"
      nil
    end
  end
end
