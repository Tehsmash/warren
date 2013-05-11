module Warren
  require 'warren/daemon_process'
  require 'warren/message_bus_manager'
  require 'json'
  class Client < Warren::DaemonProcess
    PID_LOCATION = "/Users/sambetts/.warren/warren_client.pid"
    def initialize(name)
      super(PID_LOCATION)
      @name = name
      begin
        Warren::MessageBusManager.new do |mbm|
          mbm.channel.queue("", :exclusive => true, :auto_delete => true) do |queue, declare_ok|
            data = { :name => @name, :return_queue => queue.name }
            mbm.channel.direct("").publish data.to_json, :routing_key => "warren.register" 
            queue.subscribe do |payload|
              puts "The server has registered us!"
              puts "Now subscribing to the new channel"
              exchange = mbm.channel.topic("warren.managed_nodes", :auto_delete => true)
              mbm.channel.queue(@name).bind(exchange, :routing_key => payload) do |metadata, payload|
                management(payload, mbm)
              end
            end
          end
        end
      rescue Exception => e
        puts "An Error Occured..."
        puts e
        stop
      end
      stop
    end

    def management(action, mbm)
      puts "Applying Action ..."
    end

    def stop
      puts "Shutting Down Warren Client..."
      kill
    end
  end
end
