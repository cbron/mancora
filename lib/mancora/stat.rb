module Mancora
  class Stat < ActiveRecord::Base
    attr_accessible :count, :end, :interval, :name, :start
  end
end
