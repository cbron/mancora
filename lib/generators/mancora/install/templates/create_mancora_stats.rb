class CreateMancoraStats < ActiveRecord::Migration
  def change
    create_table :mancora_stats do |t|
      t.string :name
      t.string :interval
      t.integer :count
      t.datetime :start
      t.datetime :end

      t.timestamps
    end
  end
end
