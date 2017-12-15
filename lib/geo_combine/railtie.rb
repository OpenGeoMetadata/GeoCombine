module GeoCombine
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/geo_combine.rake'
    end
  end
end
