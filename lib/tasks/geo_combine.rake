require 'net/http'
require 'json'
require 'rsolr'

namespace :geocombine do
  commit_within = (ENV['SOLR_COMMIT_WITHIN'] || 5000).to_i
  ogm_path = ENV['OGM_PATH'] || 'tmp/opengeometadata'
  solr_url = ENV['SOLR_URL'] || 'http://127.0.0.1:8983/solr/blacklight-core'
  whitelist = %w[
    git@github.com:OpenGeoMetadata/big-ten.git
  ]

  desc 'Clone all OpenGeoMetadata repositories'
  task :clone do
    ogm_api_uri = URI('https://api.github.com/orgs/opengeometadata/repos')
    ogm_repos = JSON.parse(Net::HTTP.get(ogm_api_uri)).map{ |repo| repo['git_url']}
    ogm_repos.each do |repo|
      if whitelist.include?(repo) || repo =~ /(edu|org|uk)\..*\.git$/
        system "mkdir -p #{ogm_path} && cd #{ogm_path} && git clone --depth 1 #{repo}"
      end
    end
  end

  desc '"git pull" OpenGeoMetadata repositories'
  task :pull do
    Dir.glob("#{ogm_path}/*").map{ |dir| system "cd #{dir} && git pull origin master" if dir =~ /(edu|org|uk)\..*$/ }
  end

  desc 'Index all of the GeoBlacklight JSON documents'
  task :index do
    solr = RSolr.connect :url => solr_url
    Dir.glob("#{ogm_path}/**/geoblacklight.json") do |path|
      doc = JSON.parse(File.read(path))
      begin
        solr.update params: { commitWithin: commit_within, overwrite: true },
                    data: [doc].flatten.to_json,
                    headers: { 'Content-Type' => 'application/json' }

      rescue RSolr::Error::Http => error
        puts error
      end
    end
    solr.commit
  end
end
