
require 'rubygems'
require 'eventmachine'
require 'faye'


# Event Machine server is sent plane data through JSON that it publishes
# to make available to the Javascript clients through a Faye service.

class Server < EventMachine::Connection
  attr_accessor :options, :status

  def receive_data(message)
    # create a Faye client
    client = Faye::Client.new('http://localhost:9292/faye')
       
    # publish the flight info
    client.publish('/messages/public', 'json' => message)                  
    # puts "#{@status} -- #{message}"        
  end
end

# create a service through event machine to read messages through port 2000
# and send them to Faye.

# default port is 2000, 
# but another port can be specified on the command line
port = 2000
if ARGV[0]
  port = ARGV[0].to_i
end


EventMachine.run do
  EventMachine.start_server 'localhost', port, Server do |conn|
    conn.options = {:type => 'faye_service'}
    conn.status = :OK
  end
end


