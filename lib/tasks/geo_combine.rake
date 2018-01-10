require 'net/http'
require 'json'
require 'rsolr'

namespace :geocombine do
  commit_within = (ENV['SOLR_COMMIT_WITHIN'] || 5000).to_i
  ogm_path = ENV['OGM_PATH'] || 'tmp/opengeometadata'
  solr_url = ENV['SOLR_URL'] || 'http://127.0.0.1:8983/solr/blacklight-core'
  whitelist = %w[
    https://github.com/OpenGeoMetadata/big-ten.git
  ]

  desc 'Clone OpenGeoMetadata repositories'
  task :clone, [:repo] do |_t, args|
    if args.repo
      ogm_repos = ["https://github.com/OpenGeoMetadata/#{args.repo}.git"]
    else
      ogm_api_uri = URI('https://api.github.com/orgs/opengeometadata/repos')
      ogm_repos = JSON.parse(Net::HTTP.get(ogm_api_uri)).map do |repo|
        repo['clone_url'] if repo['size'] > 0
      end.compact
      ogm_repos.select! { |repo| whitelist.include?(repo) || repo =~ /(edu|org|uk)\..*\.git$/ }
    end
    ogm_repos.each do |repo|
      system "echo #{repo} && mkdir -p #{ogm_path} && cd #{ogm_path} && git clone --depth 1 #{repo}"
    end
  end

  desc '"git pull" OpenGeoMetadata repositories'
  task :pull, [:repo] do |_t, args|
    paths = if args.repo
              [File.join(ogm_path, args.repo)]
            else
              Dir.glob("#{ogm_path}/*")
            end
    paths.each do |path|
      next unless File.directory?(path)
      system "echo #{path} && cd #{path} && git pull origin"
    end
  end

  desc 'Index all of the GeoBlacklight JSON documents'
  task :index do
    solr = RSolr.connect url: solr_url, adapter: :net_http_persistent
    puts "Indexing #{ogm_path} into #{solr_url}"
    Dir.glob("#{ogm_path}/**/geoblacklight.json") do |path|
      doc = JSON.parse(File.read(path))
      [doc].flatten.each do |record|
        begin
          puts "Indexing #{record['layer_slug_s']}: #{path}" if $DEBUG
          solr.update params: { commitWithin: commit_within, overwrite: true },
                      data: [record].to_json,
                      headers: { 'Content-Type' => 'application/json' }
        rescue RSolr::Error::Http => error
          puts error
        end
      end
    end
    solr.commit
  end
end
