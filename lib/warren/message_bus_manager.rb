module Warren
  class MessageBusManager
    def initialize(addr = "127.0.0.1")
      AMQP.start(:host => addr) do |connection|
        connection = connection
        @channel  = AMQP::Channel.new(connection)
        @stop_connection = Proc.new do
          connection.close do
            EventMachine.stop
          end
        end
        yield self
      end
    end

    def channel
      return @channel
    end

    def kill
      @stop_connection.call()
    end 
  end
end
