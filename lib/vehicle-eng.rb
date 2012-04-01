
# Vehicle engine drives movment of planes

class VehicleEngine
  
  def initialize
    @planes = Plane.find(:all)
    @planes.each{|plane| plane.prepare_simulation}
    
    # have a plane start near the map edge and move towards it  
    # Plane.setup_test_plane
  end
  
  def run
    run_num = 0
    sock = TCPSocket.new 'localhost', 2000
    loop do
      run_num += 1
      puts 'run ' + run_num.to_s if (run_num % 25 == 0)
      
      # move each plane and get the new lat/lon into JSON      
      json_ar = '[' + @planes.map{|st| st.move.important_fields.to_json }.join(',') + ']'
      
      # write the plane movements to the port for the event machine
      # engine to send to Faye
      sock.puts(json_ar)
      # p json_ar
      sock.flush
      sleep 5
    end   
  end
    
end

veng = VehicleEngine.new

puts 'running Vehicle engine ..'
veng.run



