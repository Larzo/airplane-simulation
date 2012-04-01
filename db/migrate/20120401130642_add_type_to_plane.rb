class AddTypeToPlane < ActiveRecord::Migration
  def change
    add_column 'planes', :plane_type, :string
  end
end
