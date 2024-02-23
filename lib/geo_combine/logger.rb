# frozen_string_literal: true

require 'logger'

module GeoCombine
  # Logger for gem
  class Logger
    def self.logger
      @logger ||= ::Logger.new(
        $stderr,
        progname: 'GeoCombine',
        level: ENV.fetch('LOG_LEVEL', 'info').to_sym
      )
    end
  end
end
