
# Vehicle engine drives movment of planes

class VehicleEngine
  
  def initialize
    @planes = Plane.find(:all)
    @planes.each{|plane| plane.prepare_simulation}  
  end
  
  def run
    loop do
      sock = TCPSocket.new 'localhost', 2000
      # move each plane and get the new lat/lon into JSON      
      json_ar = '[' + @planes.map{|st| st.move.important_fields.to_json }.join(',') + ']'
      
      # write the plane movements to the port for the event machine
      # engine to send to Faye
      sock.puts(json_ar)
      p json_ar
      sock.close 
      sleep 5
    end   
  end
    
end

VehicleEngine.new.run



