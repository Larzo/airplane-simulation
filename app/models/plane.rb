

class Plane < ActiveRecord::Base
  
  # set fields for simulation that influence calculation
  # of plane movements      
  def prepare_simulation
    # remember starting point
    self.longitude_origin ||= self.longitude
    self.latitude_origin ||= self.latitude
    
    self.longitude = self.longitude_origin
    self.latitude = self.latitude_origin
    
    # generate movement paramters
    self.longitude_movement = rand(2) - rand
    self.latitude_movement = rand(2) - rand
    self.save
  end
  
  # fields that need to be sent to Faye clients
  def important_fields
    {:id => self.id, :latitude => self.latitude, :longitude => self.longitude}
  end
  
  # if lat/lon are not valid because plane moved off the end of the earth
  # then reset movement parameters so caller can try again until plane 
  # moves someplace that is valid
  #
  
  def valid_latlon(lat,lon)
    valid = true
    if lat > 80 or lat < -80
      valid = false
      self.latitude_movement = rand(2) - rand
    end
    if lon > 180 or lon < -180
      valid = false
      self.longitude_movement = rand(2) - rand
    end
    self.save if !valid
    valid
  end

  # move the plane on the map and  
  # return an instance of the moved plane
  
  def move
    # calculate a valid movement
    begin
      new_lon = self.longitude + self.longitude_movement
      new_lat = self.latitude + self.latitude_movement
    end until valid_latlon(new_lat, new_lon)
    
    # move the plane
    self.longitude = new_lon
    self.latitude = new_lat
    self.save
    self
  end
  
    
end
