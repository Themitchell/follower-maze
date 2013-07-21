require 'socket'

module FollowerMaze
  class Server

    def initialize
      @event_server = TCPServer.new 9090
      @user_server = TCPServer.new 9099

      @connections = []
      @event_connection = nil
      @users = {}
    end

    def start
      Logger.info 'Starting server'

      loop do
        sockets, _, _ = IO.select(@connections + [@user_server, @event_server])

        sockets.each do |socket|
          case
          when socket == @user_server      then accept_connection socket
          when socket == @event_server     then @event_connection = accept_connection socket
          when socket == @event_connection then handle_message socket
          else create_user socket
          end
        end
      end
    end

    private
    def accept_connection socket
      Logger.info "Accepting connection"
      connection = socket.accept
      @connections << connection
      connection
    end

    def create_user socket
      id = nil
      begin
        Timeout.timeout(3) { id = socket.gets }
      rescue Timeout::Error
        Logger.error 'Timed out reading message!'
      end

      if id
        Logger.info "Creating user with id: #{id.strip}"
        @users[id.to_i] = socket
      end
    end

    def handle_message socket
      payload = nil
      begin
        Timeout.timeout(3) { payload = socket.gets }
      rescue Timeout::Error
        Logger.error 'Timed out reading message!'
      end

      if payload
        Logger.info "Handling message: #{payload.strip}"
        sequence_num, type_key, from_user_id, to_user_id = payload.strip.split('|')

        to_user   = @users[to_user_id.to_i]

        case type_key.downcase.to_sym
        when :f then follow(to_user, payload)
        when :u then unfollow
        end
      end
    end

    def follow user, payload
      user.write payload
    end

    def unfollow
      # Do nothing
    end

  end
end
