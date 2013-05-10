module Warren
  require 'warren/message_bus_manager'
  require 'warren/daemon_process'
  class Server < Warren::DaemonProcess
    PID_LOCATION = "/Users/sambetts/.warren/warren_master.pid"

    def initialize() 
      super(PID_LOCATION)
      
      begin
        Warren::MessageBusManager.new do |mbm|
          mbm.channel.queue("warren.management", :auto_delete => true).subscribe do |payload|
            server_management(payload, mbm)
          end
          mbm.channel.direct("").publish "a stupid action", :routing_key => "warren.management" 
          mbm.channel.direct("").publish "shutdown", :routing_key => "warren.management"
        end
      rescue Exception => e
        puts "Woops an error occured!"
        puts e
        stop
      end

      stop
    end

    def server_management(action, mbm)
      case action
      when "shutdown"
        puts "Initialising Shutdown...."
        mbm.kill
      when "new config"
        puts "Pushing New Config...."
      else
        puts "Unrecognised Action - #{action} - Received, Doing Nothing!...."
      end
    end

    def stop
      puts "Shutting Down the Warren Server Daemon....."
      kill
    end
  end
end
