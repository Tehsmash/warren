module Warren
  class DaemonProcess
    def initialize(pid_location)
      @location = pid_location
      if File.exists?(@location)
        raise "Daemon already running - end or delete #{@location}"
      end
      @pid = pid

      pid_file = open(@location, "w")
      pid_file.puts @pid
    end

    def pid
      return @pid || Process.pid
    end

    def kill
      File.unlink(@location) if File.exists?(@location) 
      exit
    end
  end
end
