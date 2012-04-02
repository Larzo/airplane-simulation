

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
  
  # we may need a plane that will start out near the map edge and move towards it
  def self.setup_test_plane
    tplane = self.find_by_plane_type('test')
    if !tplane
      tplane = self.new(:plane_type => 'test')
      tplane.save
    end
    tplane.latitude = 75
    tplane.latitude_movement = 0.9
    tplane.longitude = -30
    tplane.longitude_movement = 0.1
    tplane.save 
  end
  
  # flag planes that are near edge of map,
  # this is just for testing/diagnostic purposes
  #
  def rpt_flag
    flag = ""
    if self.latitude > 70 or self.latitude < -70
      flag = "*"
    end
    if self.longitude > 170 or self.longitude < -170
      flag = "*"
    end
    flag
  end
  
  # console report facility
  #
  def self.console_rpt
    self.find(:all).each do |plane|
      puts plane.rpt_flag + 
      plane.id.to_s + ':' + 
      plane.latitude.to_s + ',' + plane.longitude.to_s      
    end
    ""
  end
  
  # fields that need to be sent to Faye clients
  def important_fields
    {:id => self.id, :latitude => self.latitude, :longitude => self.longitude}
  end
  
  # if lat/lon are not valid because plane is close to moving 
  # off the end of the map then reset movement parameters. This is so 
  # caller can try a move again until plane moves someplace away from that
  # map edge
  #
  
  def near_map_edge(lat,lon)
    near_edge = false
    if lat > 80 or lat < -80
      near_edge = true
      self.latitude_movement = rand(2) - rand
    end
    if lon > 180 or lon < -180
      near_edge = true
      self.longitude_movement = rand(2) - rand
    end
    self.save if near_edge    
=begin    
    if near_edge
      puts '------------------ NEAR MAP EDGE -----------------'
      p Time.now
      p self
    end
=end    
    near_edge
  end

  # move the plane on the map and  
  # return an instance of the moved plane
  
  def move
    # calculate a desired movement that won't go off the map
    begin
      new_lon = self.longitude + self.longitude_movement
      new_lat = self.latitude + self.latitude_movement
    end until !near_map_edge(new_lat, new_lon)
    
    # move the plane
    self.longitude = new_lon
    self.latitude = new_lat
    self.save
    self
  end
  
    
end
