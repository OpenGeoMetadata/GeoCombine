# frozen_string_literal: true

require 'geo_combine/logger'

RSpec.describe GeoCombine::Logger do
  around do |example|
    original_level = ENV.fetch('LOG_LEVEL', nil)
    described_class.instance_variable_set(:@logger, nil)
    example.run
  ensure
    ENV['LOG_LEVEL'] = original_level # assigning nil deletes the key
    described_class.instance_variable_set(:@logger, nil)
  end

  describe '.logger' do
    it 'returns a Logger instance' do
      expect(described_class.logger).to be_a(Logger)
    end

    it 'shares a single logger instance across the gem' do
      logger1 = described_class.logger
      logger2 = described_class.logger
      expect(logger1).to equal(logger2)
    end

    it 'sets the log level based on the LOG_LEVEL environment variable' do
      ENV['LOG_LEVEL'] = 'debug'
      logger = described_class.logger
      expect(logger.level).to eq(Logger::DEBUG)
    end

    it 'defaults to INFO level if LOG_LEVEL is not set' do
      ENV.delete('LOG_LEVEL')
      logger = described_class.logger
      expect(logger.level).to eq(Logger::INFO)
    end
  end
end
