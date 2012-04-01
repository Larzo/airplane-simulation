class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.float :longitude
      t.float :latitude
      t.string :description
      t.timestamps
    end
  end
end
