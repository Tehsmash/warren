class Warren::Server::Node
  def initialize(name, queue)
    @name = name
    @queue = queue
    @registered = false
  end

  def name
    @name
  end

  def current_queue(queue = @queue)
    @queue = queue
  end

  def registered(reg = @registered)
    @registered = reg
  end
end
