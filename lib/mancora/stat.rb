module Mancora
  class Stat < ActiveRecord::Base
    attr_accessible :count, :end, :intervals, :name, :start
  end
end
