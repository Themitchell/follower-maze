
module FollowerMaze
  class Connection

    attr_reader :socket

    def initialize socket
      @socket = socket
    end

    def read
      payload = nil
      begin
        Timeout.timeout(TIMEOUT) { payload = socket.gets }
      rescue Timeout::Error
        Logger.warn 'Connection: Timed out reading from socket!'
      end
      payload
    end

    def fileno
      socket.fileno
    end

  end
end
