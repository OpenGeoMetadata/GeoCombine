# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'
require 'geo_combine/harvester'
require 'geo_combine/indexer'
require 'geo_combine/withdrawals'
require 'spec_helper'

RSpec.describe GeoCombine::Withdrawals do
  subject(:withdrawals) { described_class.new(ogm_path:, skip_repos:, logger:) }

  let(:ogm_path) { 'spec/fixtures/withdrawal' }
  let(:skip_repos) { [] }
  let(:logger) { instance_double(Logger, warn: nil, info: nil, error: nil, debug: nil) }

  # Write a withdrawal log into a temporary ogm_path
  def write_log(path, content)
    FileUtils.mkdir_p(File.dirname(File.join(ogm_path, path)))
    File.binwrite(File.join(ogm_path, path), content.is_a?(String) ? content : content.to_json)
  end

  def log_of(*entries)
    { '$schema' => 'https://opengeometadata.org/schema/ogm-withdrawals-1.0.json', 'ogm_version' => '1.0', 'withdrawn' => entries }
  end

  describe '#paths' do
    it 'finds the log at the root of each repository, in order' do
      expect(withdrawals.paths).to eq %w[
        spec/fixtures/withdrawal/edu.example-a/withdrawn.json
        spec/fixtures/withdrawal/edu.example-b/withdrawn.json
        spec/fixtures/withdrawal/edu.example-broken/withdrawn.json
        spec/fixtures/withdrawal/edu.example-skipped/withdrawn.json
      ]
    end

    it 'ignores the logs of repositories that are not being harvested' do
      withdrawals = described_class.new(ogm_path:, skip_repos: ['edu.example-skipped'], logger:)
      expect(withdrawals.paths).not_to include('spec/fixtures/withdrawal/edu.example-skipped/withdrawn.json')
    end

    it 'reads the repositories not being harvested from OGM_SKIP_REPOS' do
      stub_const('ENV', ENV.to_h.merge('OGM_SKIP_REPOS' => 'edu.example-a, edu.example-b'))
      withdrawals = described_class.new(ogm_path:, logger:)
      expect(withdrawals.paths).to eq %w[
        spec/fixtures/withdrawal/edu.example-broken/withdrawn.json
        spec/fixtures/withdrawal/edu.example-skipped/withdrawn.json
      ]
    end

    it 'finds the log of a single repository given as ogm_path' do
      withdrawals = described_class.new(ogm_path: 'spec/fixtures/withdrawal/edu.example-a', logger:)
      expect(withdrawals.paths).to eq ['spec/fixtures/withdrawal/edu.example-a/withdrawn.json']
    end

    it 'finds nothing when no repository publishes a log' do
      withdrawals = described_class.new(ogm_path: 'spec/fixtures/indexing', logger:)
      expect(withdrawals.paths).to eq []
    end

    it 'finds nothing when ogm_path is a single file' do
      withdrawals = described_class.new(ogm_path: 'spec/fixtures/indexing/aardvark.json', logger:)
      expect(withdrawals.paths).to eq []
    end

    it 'ignores logs that are not at the root of a repository' do
      expect(withdrawals.paths).not_to include(a_string_matching(/metadata-aardvark/))
    end
  end

  describe '#entries' do
    it 'reads entries keyed by id' do
      entry = withdrawals.entries['b-gone']
      expect(entry.to_h).to eq(id: 'b-gone', date: '2026-04-01', reason: 'superseded',
                               source_path: 'spec/fixtures/withdrawal/edu.example-b/withdrawn.json')
    end

    it 'reads every valid entry of every log' do
      expect(withdrawals.entries.keys).to contain_exactly(
        'a-gone', 'a-contradicted', 'b-live', 'a-never-indexed', 'a-embargoed', 'b-gone', 'skipped-gone'
      )
    end

    it 'treats an unrecognized reason as other' do
      expect(withdrawals.entries['a-embargoed'].reason).to eq 'other'
    end

    it 'leaves the reason empty when there is none' do
      expect(withdrawals.entries['a-never-indexed'].reason).to be_nil
    end

    it 'skips entries with an id that is padded with whitespace' do
      expect(withdrawals.entries.keys).not_to include(' a-padded ', 'a-padded')
      expect(logger).to have_received(:error)
        .with('skipping entry 4 in withdrawal log spec/fixtures/withdrawal/edu.example-a/withdrawn.json: unusable id " a-padded "')
    end

    it 'skips entries with no date' do
      expect(withdrawals.entries.keys).not_to include('a-undated')
      expect(logger).to have_received(:error)
        .with('skipping entry 5 in withdrawal log spec/fixtures/withdrawal/edu.example-a/withdrawn.json: invalid date nil for a-undated')
    end

    it 'skips a malformed log, and still reads the others' do
      expect(withdrawals.entries.keys).not_to include('local-only')
      expect(logger).to have_received(:error)
        .with(%r{^skipping withdrawal log spec/fixtures/withdrawal/edu.example-broken/withdrawn.json: })
    end

    context 'with logs written for the occasion' do
      let(:ogm_path) { Dir.mktmpdir }

      after { FileUtils.remove_entry(ogm_path) }

      it 'lets the last entry win when an id is listed twice' do
        write_log('repo/withdrawn.json', log_of({ id: 'a', date: '2026-01-01' }, { id: 'a', date: '2026-02-01', reason: 'rights' }))
        expect(withdrawals.entries['a'].to_h).to include(date: '2026-02-01', reason: 'rights')
      end

      it 'reads the log at the root of ogm_path' do
        write_log('withdrawn.json', log_of({ id: 'a', date: '2026-01-01' }))
        expect(withdrawals.entries.keys).to eq ['a']
      end

      it 'accepts W3C-DTF dates and date-times' do
        dates = %w[2026 2026-03 2026-03-14 2026-03-14T12:00Z 2026-03-14T12:00:00-05:00 2026-03-14T12:00:00.5+01:00]
        write_log('repo/withdrawn.json', log_of(*dates.map.with_index { |date, n| { id: "id-#{n}", date: } }))
        expect(withdrawals.entries.size).to eq dates.size
      end

      it 'rejects dates that are not W3C-DTF' do
        dates = ['03/14/2026', '2026-03-14 12:00', '2026-03-14T12:00:00', 20_260_314]
        write_log('repo/withdrawn.json', log_of(*dates.map.with_index { |date, n| { id: "id-#{n}", date: } }))
        expect(withdrawals.entries).to be_empty
      end

      it 'skips entries that are not objects' do
        write_log('repo/withdrawn.json', log_of('a', { id: 'b', date: '2026-01-01' }))
        expect(withdrawals.entries.keys).to eq ['b']
        expect(logger).to have_received(:error).with(/skipping entry 0 .*: not a JSON object/)
      end

      it 'skips entries with an id that is not a string' do
        write_log('repo/withdrawn.json', log_of({ id: 5, date: '2026-01-01' }, { date: '2026-01-01' }))
        expect(withdrawals.entries).to be_empty
      end

      it 'accepts a log that does not declare its version' do
        write_log('repo/withdrawn.json', { withdrawn: [{ id: 'a', date: '2026-01-01' }] })
        expect(withdrawals.entries.keys).to eq ['a']
      end

      it 'skips a log with an unsupported version' do
        write_log('repo/withdrawn.json', log_of({ id: 'a', date: '2026-01-01' }).merge('ogm_version' => '2.0'))
        expect(withdrawals.entries).to be_empty
        expect(logger).to have_received(:error).with(/skipping withdrawal log .*: unsupported ogm_version 2.0/)
      end

      it 'skips a log that is not shaped like a withdrawal log' do
        write_log('a/withdrawn.json', [{ id: 'a', date: '2026-01-01' }])
        write_log('b/withdrawn.json', { withdrawn: { id: 'b', date: '2026-01-01' } })
        expect(withdrawals.entries).to be_empty
        expect(logger).to have_received(:error).with(/: not a JSON object with a "withdrawn" array/).twice
      end

      it 'skips a log that is not valid UTF-8' do
        write_log('repo/withdrawn.json', "{\"withdrawn\": [{\"id\": \"\xC3(\", \"date\": \"2026-01-01\"}]}".b)
        expect(withdrawals.entries).to be_empty
        expect(logger).to have_received(:error).with(/skipping withdrawal log .*: not valid UTF-8/)
      end

      it 'reads UTF-8 logs with a byte order mark when the default external encoding is not UTF-8' do
        original = Encoding.default_external
        Encoding.default_external = Encoding::US_ASCII
        write_log('repo/withdrawn.json', "\uFEFF#{log_of({ id: 'bogotá-1', date: '2026-01-01' }).to_json}")
        expect(withdrawals.entries.keys).to eq ['bogotá-1']
      ensure
        Encoding.default_external = original
      end
    end
  end

  describe '#apply' do
    let(:harvester) { instance_double(GeoCombine::Harvester, walk_complete?: true, present_ids: Set['a-contradicted', 'b-live']) }
    let(:indexer) { instance_double(GeoCombine::Indexer) }

    before do
      allow(indexer).to receive(:delete) { |ids| ids }
    end

    it 'deletes every withdrawn id that is not published, whether or not it is indexed' do
      expect(withdrawals.apply(harvester:, indexer:)).to eq %w[a-gone a-never-indexed a-embargoed b-gone skipped-gone]
      expect(indexer).to have_received(:delete).with(%w[a-gone a-never-indexed a-embargoed b-gone skipped-gone])
    end

    it 'never deletes a record that is still published, and says why' do
      withdrawals.apply(harvester:, indexer:)
      expect(indexer).not_to have_received(:delete).with(include('a-contradicted'))
      expect(logger).to have_received(:warn)
        .with('not deleting b-live; it is withdrawn in spec/fixtures/withdrawal/edu.example-a/withdrawn.json but still published')
    end

    it 'logs a summary' do
      withdrawals.apply(harvester:, indexer:)
      expect(logger).to have_received(:info).with('withdrawals: 7 entries, 2 still published, 5 deleted or already absent')
    end

    context 'when no repository withdraws anything' do
      let(:ogm_path) { 'spec/fixtures/indexing' }

      it 'leaves solr alone' do
        expect(withdrawals.apply(harvester:, indexer:)).to eq []
        expect(indexer).not_to have_received(:delete)
      end
    end

    context 'when the harvest did not walk every record' do
      let(:harvester) { instance_double(GeoCombine::Harvester, walk_complete?: false) }

      it 'deletes nothing' do
        expect(withdrawals.apply(harvester:, indexer:)).to eq []
        expect(indexer).not_to have_received(:delete)
        expect(logger).to have_received(:error).with('not deleting withdrawn records; the harvest did not walk every record')
      end
    end
  end

  # The behavior matrix in the design, end to end: a real walk of fixture repositories,
  # real logs, and a Solr that holds documents in memory
  describe 'indexing, then applying withdrawals' do
    let(:skip_repos) { ['edu.example-skipped'] }
    let(:harvester) { GeoCombine::Harvester.new(ogm_path:, skip_repos:, logger:) }
    let(:indexer) { GeoCombine::Indexer.new(solr:, logger:) }
    let(:solr) { instance_double(RSolr::Client, options: { url: 'TEST' }) }
    let(:index) do
      {
        'a-gone' => { 'id' => 'a-gone' },                 # withdrawn, record file gone
        'a-contradicted' => { 'id' => 'a-contradicted' }, # withdrawn, but still published by the same repo
        'b-live' => { 'id' => 'b-live' },                 # withdrawn by repo a, still published by repo b
        'b-gone' => { 'id' => 'b-gone' },                 # withdrawn, record file gone
        'a-orphan' => { 'id' => 'a-orphan' },             # record file gone, but never withdrawn
        'local-only' => { 'id' => 'local-only' },         # only listed in a malformed log
        'skipped-gone' => { 'id' => 'skipped-gone' },     # withdrawn by a repo that is not harvested
        'a-padded' => { 'id' => 'a-padded' }              # listed, with whitespace around it
      }
    end

    let(:calls) { [] }

    before do
      allow(solr).to receive(:update) do |opts|
        calls << :add
        # One document per line, as Indexer#batch_json writes them
        opts[:data].each_line do |line|
          doc = JSON.parse(line[/doc: (\{.*\}) \}(?:,| \})\s*\z/, 1])
          index[doc['id']] = doc
        end
      end
      allow(solr).to receive(:commit) { calls << :commit }
      allow(solr).to receive(:delete_by_id) do |ids|
        calls << :delete
        Array(ids).each { |id| index.delete(id) }
      end
    end

    def index_then_withdraw
      indexer.index(harvester.docs_to_index)
      withdrawals.apply(harvester:, indexer:)
    end

    it 'deletes the withdrawn records that are no longer published, and nothing else' do
      index_then_withdraw
      expect(index.keys).to contain_exactly('a-contradicted', 'b-live', 'a-live', 'a-orphan', 'local-only', 'skipped-gone', 'a-padded')
    end

    it 'commits its adds before it deletes' do
      index_then_withdraw
      expect(calls).to eq %i[add commit delete commit]
    end

    it 'changes nothing when run again' do
      index_then_withdraw
      expect { index_then_withdraw }.not_to(change { index.keys.sort })
    end

    it 'deletes records withdrawn by a repository once it is harvested' do
      harvester = GeoCombine::Harvester.new(ogm_path:, skip_repos: [], logger:)
      withdrawals = described_class.new(ogm_path:, skip_repos: [], logger:)
      indexer.index(harvester.docs_to_index)
      withdrawals.apply(harvester:, indexer:)
      expect(index).not_to have_key('skipped-gone')
    end
  end
end
