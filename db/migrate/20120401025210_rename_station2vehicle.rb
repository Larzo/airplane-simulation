class RenameStation2vehicle < ActiveRecord::Migration
  def up
    rename_table :stations, :planes
  end

  def down
    rename_table :planes, :stations
  end
end
