require 'warren/message_bus_manager'
require 'warren/daemon_process'

class Warren::Server < Warren::DaemonProcess
  PID_LOCATION = "/Users/sambetts/.warren/warren_master.pid"

  def initialize() 
    super(PID_LOCATION)

    @groups = []      
    @nodes = []
    @tasks = []

    begin
      Warren::MessageBusManager.new do |mbm|
        mbm.channel.queue("warren.management", :auto_delete => true).subscribe do |payload|
          server_management(payload, mbm)
        end

        mbm.channel.queue("warren.register", :auto_delete => true).subscribe do |payload|
          data = JSON.parse(payload)
          puts "Machine requesting registration.... "
          puts payload
          node = Node.new(data['name'], data['return_queue'])
          @nodes.push(node)
        end

        exchange = mbm.channel.topic("warren.managed_nodes", :auto_delete => true)
      end
    rescue Exception => e
      puts "Woops an error occured!"
      puts e
      stop
    end

    stop
  end

  def add_task(instruction, task)
    pieces = instruction.split(".")
    current = tasks
    pieces.each do |piece|
      current = tasks[piece]
      if current.nil?
        current = []
      end
    end
  end

  def server_management(action, mbm)
    case action
    when "shutdown" then shutdown_queues(mbm)
    when "config.new" then puts "Pushing New Config...."
    when "nodes.list" then list_nodes
    when "nodes.accept.all" then accept_nodes(mbm)
    else
      puts "Unrecognised Action - #{action} - Received, Doing Nothing!...."
    end
  end

  def shutdown_queues(mbm)
    puts "Initialising Shutdown...."
    mbm.kill_now
  end

  def list_nodes(mbm)
    @nodes.each do |node|
      puts "Node: #{node.name}, Registered: #{node.registered}"
    end
  end

  def accept_nodes(mbm)
    puts "Accepting All Unregistered Nodes..."
    @nodes.each do |node|
      unless node.registered
        # Look in the config for the machine
        # Send back the right queue for the machine to hook into  
        mbm.channel.direct("").publish "default", :routing_key => node.current_queue
      end
    end
    puts "Done..."
  end

  def stop
    puts "Shutting Down the Warren Server Daemon....."
    kill
  end
end

require 'warren/server/node'
