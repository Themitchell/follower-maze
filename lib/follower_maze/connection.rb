
module FollowerMaze
  class Connection

    attr_reader :socket

    def initialize socket
      @socket = socket
    end

    class ReadError < StandardError; end
    class WriteError < StandardError; end

    def read
      payload = nil
      begin
        Logger.info "Connection: Reading message from Connection #{fileno}"
        Timeout.timeout(TIMEOUT) { payload = socket.gets("\n") }
      rescue Timeout::Error
        raise ReadError.new "Timed out!"
      rescue Errno::EPIPE
        raise ReadError.new "Socket not connected!"
      rescue Errno::ECONNRESET
        raise ReadError.new "Connection reset!"
      end
      payload
    end

    def write payload
      Logger.info "Connection: Writing message to Connection #{fileno}"
      Timeout.timeout(TIMEOUT) { socket.write payload }
    rescue Timeout::Error
      raise WriteError.new "Timed out!"
    rescue Errno::EPIPE
      raise WriteError.new "Socket not connected!"
    rescue Errno::ECONNRESET
      raise WriteError.new "Connection reset!"
    end

    def fileno
      socket.fileno
    end

  end
end
