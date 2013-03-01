require "mancora/version"
require 'mancora/widget'
require 'mancora/stat'


module Mancora
  extend self
  
  def self.table_name_prefix
    'mancora_'
  end

  def self.run(backfill = 0)
    @backfill = backfill
    puts "Backfilling " + (@backfill || 0).to_s  + " hours." if @backfill > 0
    load Rails.root.join('lib', 'mancora.rb')
  end

  def widgets(hash = {}, &block)  
    instance_eval(&block) if block_given?
  end

  def widget(opt, options = {}, &block)
    Widget.new(opt, @backfill, &block)
  end
end