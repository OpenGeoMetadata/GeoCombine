# frozen_string_literal: true

require 'thor'
require 'rake'

root = Gem::Specification.find_by_name('geo_combine').gem_dir
tasks = File.join(root, 'lib/tasks/*.rake')
Dir.glob(tasks).each { |r| load r }

module GeoCombine
  class CLI < Thor
    desc 'clone', 'Clone all OpenGeoMetadata repositories'
    def clone
      Rake::Task['geocombine:clone'].invoke
    end

    desc 'pull', '"git pull" OpenGeoMetadata repositories'
    def pull
      Rake::Task['geocombine:pull'].invoke
    end

    desc 'index', 'Index all of the GeoBlacklight documents'
    def index
      Rake::Task['geocombine:index'].invoke
    end
  end
end
