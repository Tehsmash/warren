module Warren
  require 'warren/daemon_process'
  require 'warren/message_bus_manager'
  class Client < Warren::DaemonProcess
    PID_LOCATION = "/Users/sambetts/.warren/warren_client.pid"
    def initialize(name)
      super(PID_LOCATION)
      @name = name
      begin
        Warren::MessageBusManager.new do |mbm|
          mbm.channel.direct("").publish @name, :routing_key => "warren.register"
          mbm.channel.queue(@name, :auto_delete => true).subscribe do |payload|
            puts "A RESPONSE FROM THE SERVER!!!!"
            mbm.kill_now
          end
        end
      rescue Exception => e
        puts "An Error Occured..."
        puts e
        stop
      end
      stop
    end

    def stop
      puts "Shutting Down Warren Client..."
      kill
    end
  end
end
