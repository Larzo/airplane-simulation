
require 'rubygems'
require 'eventmachine'
require 'faye'


# Event Machine server is sent messages that it publishes
# to the chat room through a Faye service.

class Server < EventMachine::Connection
  attr_accessor :options, :status

  def receive_data(message)
    # create a Faye client
    client = Faye::Client.new('http://localhost:9292/faye')
    
    p message
    
    # publish the message to the chat room    
    client.publish('/messages/public', 'json' => message)                  
    puts "#{@status} -- #{message}"        
  end
end

# create a service through event machine to read messages through port 2000
# and send them to the chat room.

EventMachine.run do
  EventMachine.start_server 'localhost', 2000, Server do |conn|
    conn.options = {:type => 'faye_service'}
    conn.status = :OK
  end
end


