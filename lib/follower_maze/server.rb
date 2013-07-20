require 'socket'

module FollowerMaze
  class Server

    def initialize
      @event_server = TCPServer.new 9090
      @user_server = TCPServer.new 9099

      @connections = []
    end

    def start
      Logger.info 'Starting server..'

      loop do
        sockets, _, _ = IO.select(@connections + [@user_server, @event_server])

        sockets.each do |socket|
          [@user_server, @event_server].include? socket or next
          Logger.info "Accepting connection.."
          connection = socket.accept
          @connections << connection
        end

      end

    end

  end
end
