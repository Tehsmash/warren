module Warren
  require 'warren/message_bus_manager'
  require 'warren/daemon_process'
  class Server < Warren::DaemonProcess
    PID_LOCATION = "/Users/sambetts/.warren/warren_master.pid"

    def initialize() 
      super(PID_LOCATION)
      
      @unregistered_nodes = []
      @registered_nodes = []

      begin
        Warren::MessageBusManager.new do |mbm|
          mbm.channel.queue("warren.management", :auto_delete => true).subscribe do |payload|
            server_management(payload, mbm)
          end

          mbm.channel.queue("warren.register", :auto_delete => true).subscribe do |payload|
            @unregistered_nodes.push(payload)
          end
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
      when "shutdown" then shutdown_queues(mbm)
      when "new config" then puts "Pushing New Config...."
      when "unregistered_nodes list" then list_unreg_nodes
      when "unregistered_nodes accept" then accept_nodes(mbm)
      when "registered_nodes list" then list_reg_nodes
      else
        puts "Unrecognised Action - #{action} - Received, Doing Nothing!...."
      end
    end

    def shutdown_queues(mbm)
      puts "Initialising Shutdown...."
      mbm.kill_now
    end

    def list_unreg_nodes
      @unregistered_nodes.each do |node|
        puts node
      end
    end

    def list_reg_nodes
      @registered_nodes.each do |node|
        puts node
      end
    end

    def accept_nodes(mbm)
      while @unregistered_nodes.length > 0
        node = @unregistered_nodes.pop
        @registered_nodes.push(node)
        mbm.channel.direct("").publish "HELLO YOU WEIRD THING!", :routing_key => node
      end
    end

    def stop
      puts "Shutting Down the Warren Server Daemon....."
      kill
    end
  end
end
