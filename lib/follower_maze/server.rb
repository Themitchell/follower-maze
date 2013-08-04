require 'socket'
require 'timeout'
require './lib/follower_maze/connection'
require './lib/follower_maze/user_store'
require './lib/follower_maze/user'
require './lib/follower_maze/event'
require './lib/follower_maze/event_queue'

module FollowerMaze
  class Server

    def initialize
      @event_server     = TCPServer.new 9090
      @event_connection = nil

      @user_server      = TCPServer.new 9099
      @connections      = {}

      @events = {}
      @event_queue = EventQueue.new
    end

    class NotificationError < StandardError; end

    def start
      Logger.info 'Starting server'

      loop do

        readable_sockets, writable_sockets, _ = IO.select(@connections.values.map(&:socket) + [@user_server, @event_server], @connections.values.map(&:socket))

        readable_sockets.each do |socket|
          case
          when [@user_server, @event_server].include?(socket)
            io = socket.accept
            @connections[io.fileno] = Connection.new(io)
            @event_connection = io if socket == @event_server
          when socket == @event_connection
            handle_message socket
          else
            create_user socket
          end
        end

        @event_queue.process_events

        writable_sockets.each do |socket|
          connection = @connections[socket.fileno]
          break unless connection
          user = UserStore.find_by_connection(connection)
          if user
            begin
              connection.write user.messages_to_send
            rescue Connection::WriteError => e
              Logger.warn "Server: Notifying Connection #{connection.fileno} failed due to: #{e}"
            else
              user.reset_messages!
            end
          end
        end

      end
    end

    private
    def create_user socket
      connection = @connections[socket.fileno]

      begin
        id = connection.read
        user = UserStore.create_or_update(id, connection)
      rescue Connection::ReadError => e
        @connections.delete socket.fileno
        Logger.warn "Server: Failed to create user with Connection::ReadError: #{e}"
      end
    end

    def handle_message socket
      connection = @connections[socket.fileno]

      if payload = connection.read
        @event_queue.add_event Event.new payload
      end
    end

  end
end
