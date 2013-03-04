require 'mancora'
require 'rails'
module Mancora
  class Railtie < Rails::Railtie
    railtie_name :mancora

    rake_tasks do
      load "tasks/tasks.rake"
    end
  end
end