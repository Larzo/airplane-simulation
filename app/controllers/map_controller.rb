class MapController < ApplicationController
  layout "map_layout"
  
  def index
    @planes = Plane.find(:all)
  end
end
