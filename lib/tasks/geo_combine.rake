require 'find'
require 'net/http'
require 'json'
require 'rsolr'

namespace :geocombine do
  ogm_path = ENV['OGM_PATH'] || 'tmp/opengeometadata'
  solr_url = ENV['SOLR_URL'] || 'http://127.0.0.1:8983/solr/blacklight-core'
  desc 'Clone all OpenGeoMetadata repositories'
  task :clone do
    ogm_api_uri = URI('https://api.github.com/orgs/opengeometadata/repos')
    ogm_repos = JSON.parse(Net::HTTP.get(ogm_api_uri)).map{ |repo| repo['git_url']}
    ogm_repos.each do |repo|
      if repo =~ /^git:\/\/github.com\/OpenGeoMetadata\/(edu|org|uk)\..*/
        system "mkdir -p #{ogm_path} && cd #{ogm_path} && git clone --depth 1 #{repo}"
      end
    end
  end
  desc '"git pull" OpenGeoMetadata repositories'
  task :pull do
    Dir.glob("#{ogm_path}/*").map{ |dir| system "cd #{dir} && git pull origin master" if dir =~ /.*(edu|org|uk)\..*./ }
  end
  desc 'Index all of the GeoBlacklight documents'
  task :index do
    solr = RSolr.connect :url => solr_url
    Find.find(ogm_path) do |path|
      next unless path =~ /.*geoblacklight.json$/
      doc = JSON.parse(File.read(path))
      begin
        solr.update params: { commitWithin: 500, overwrite: true },
                    data: [doc].to_json,
                    headers: { 'Content-Type' => 'application/json' }

      rescue RSolr::Error::Http => error
        puts error
      end
    end
  end
end
