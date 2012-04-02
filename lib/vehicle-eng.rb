

require File.expand_path(File.dirname(__FILE__)) + '/misc'


if Kernel.is_windows?
  require 'win32/process'
end


# Vehicle engine drives movment of planes

class VehicleEngine
  
  def initialize
    @planes = Plane.find(:all)
    @planes.each{|plane| plane.prepare_simulation}
    @run_num = 0
    
    # have a plane start near the map edge and move towards it  
    # Plane.setup_test_plane
  end
  
  # support the case where the socket is not available and general robustness.
  #
  # The event machine port service could go down or need restarting.
  # In that case we will have to wait for it to come back up.
  # in the meantime, the socket connection may error out and we need
  # to handle that. 
  # We look for event machine on 3 different ports in case multiple
  # instances of event machine might need to be used also. 
  
  def get_socket
    hi_port = 2002
    ports = (2000..hi_port).to_a    
    @pidx ||= 0
   
    port = nil
    
    # loop until we get a valid open socket
    # on one of the ports. The current socket
    # may be appear valid. In that case we don't
    # enter the loop.
    count = 0
    while !@sock
      begin
        port = ports[@pidx]        
        @sock = TCPSocket.new 'localhost', port
        puts 'got socket for ' + port.to_s
      rescue
        puts 'unable to obtain socket .. ' if (count % 5 == 0)
        @pidx += 1
        @pidx = 0 if @pidx >= ports.length
        sleep 1
      end
      count += 1
      
    end
    @sock
  end
  
  # main driver loop
  #
  # 
  
  def run
    @run_num = 0
#    start_port_svc
    done = false
    while !done do
      @sock = get_socket
      @run_num += 1
      puts 'run ' + @run_num.to_s if (@run_num % 20 == 0)
      
      # move each plane and get the new lat/lon into JSON  
      begin 
        if !@json   
          @json_ar = '[' + 
          @planes.map{|st| st.move.important_fields.to_json }.join(',') + 
          ']'
        end
        # write the plane movements to the port for the event machine
        # engine to send to Faye
        @sock.puts(@json_ar)
        @json_ar = nil
        # p json_ar
        @sock.flush
      rescue
        # the socket may have gone down 
        @sock = nil
        puts 'socket connection temporaliy lost'
      end
      sleep 5 if @sock
    end   
  end
    
end

veng = VehicleEngine.new

puts 'running Vehicle engine ..'
veng.run



