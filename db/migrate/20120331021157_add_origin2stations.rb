class AddOrigin2stations < ActiveRecord::Migration
  def up
    add_column 'stations', :longitude_origin, :float
    add_column 'stations', :latitude_origin, :float
    add_column 'stations', 'latitude_movement', :float
    add_column 'stations', 'longitude_movement', :float
    add_column 'stations', 'speed', :integer
  end

  def down
  end
end
