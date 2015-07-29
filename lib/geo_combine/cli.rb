require 'thor'
require 'rake'

Dir.glob('lib/tasks/geo_combine.rake').each { |r| load r }

module GeoCombine
  class CLI < Thor
    desc 'clone', 'Clone all OpenGeoMetadata repositories'
    def clone
      Rake::Task['geocombine:clone'].invoke
    end

    desc 'pull', '"git pull" OpenGeoMetadata repositories'
    def pull
      Rake::Task['geocombine:pull']
    end

    desc "index", "Index all of the GeoBlacklight documents"
    def index
      Rake::Task['geocombine:index'].invoke
    end
  end
end
