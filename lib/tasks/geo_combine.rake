require 'find'
require 'net/http'
require 'json'
require 'rsolr'
require 'fileutils'
require 'dotenv/tasks'

namespace :geocombine do
  desc 'Clone and index all in one go'
  task :all, [:solr_url] => [:clone, :index]

  ogm_path = ENV['OGM_PATH'] || 'tmp/opengeometadata'
  desc 'Clone all OpenGeoMetadata repositories'
  task :clone do
    FileUtils.mkdir_p(ogm_path)
    ogm_api_uri = URI('https://api.github.com/orgs/opengeometadata/repos')
    ogm_repos = JSON.parse(Net::HTTP.get(ogm_api_uri)).map{ |repo| repo['git_url']}
    ogm_repos.each do |repo|
      if repo =~ /^git:\/\/github.com\/OpenGeoMetadata\/edu.*/
        system "mkdir -p #{ogm_path} && cd #{ogm_path} && git clone #{repo}"
      end
    end
  end

  desc 'Delete the tmp directory'
  task :clean do
    puts "Removing 'tmp' directory." if verbose == true
    FileUtils.rm_rf(ogm_path) 
  end

  desc "Delete the Solr index"
  task :delete , [:solr_url]  => :dotenv do |t, args|
    begin
      args.with_defaults(solr_url: ENV.fetch('solr_url', 'http://127.0.0.1:8983/solr'))
      solr = RSolr.connect :url => args[:solr_url]
      puts "Deleting the Solr index." if verbose == true
      solr.delete_by_query '*:*'
      solr.optimize
    rescue Exception => e
      puts "\nError: #{e}" if verbose == true
    end
  end

  desc '"git pull" OpenGeoMetadata repositories'
  task :pull do
    Dir.glob("#{ogm_path}/*").map{ |dir| system "cd #{dir} && git pull origin master" if dir =~ /.*edu.*./ }
  end

  desc 'Index all of the GeoBlacklight documents'
  task :index, [:solr_url] => :dotenv do |t, args|
    begin
      args.with_defaults(solr_url: ENV.fetch('solr_url', 'http://127.0.0.1:8983/solr'))
      solr = RSolr.connect :url => args[:solr_url], :read_timeout => 720

      puts "Finding geoblacklight.xml files." if verbose == true
      xml_files = Dir.glob("#{ogm_path}/**/*geoblacklight.xml")

      puts "Loading files into solr." if verbose == true
      xml_files.each_with_index do |file, i|
        @the_file = file
        doc = File.read(file)
        begin
          solr.update data: doc
        rescue RSolr::Error::Http => error
          puts "\n#{file}\n#{error}" if verbose == true
          next
        end

        if verbose == true
          if i % 100 == 0 && i > 0
            print "." 
            if i % 1000 == 0
              puts " #{i} files uploaded."
            end
          end
        end
      end

    rescue Exception => e
      puts "\n#{@the_file}\nError: #{e}" if verbose == true
      next
    end

    puts "\nIndexing and optimizing Solr." if verbose == true
    solr.commit
    solr.optimize
    puts "\n" if verbose == true
  end
end
