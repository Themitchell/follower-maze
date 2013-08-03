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

        while @event_queue.has_events?
          event = @event_queue.next_event
          break unless event

          begin
            event.process
          rescue FollowerMaze::Event::ProcessingError => e
            Logger.warn "Server: ProcessingError for event #{event.sequence_num}: #{e}"
          end

          @event_queue.complete_event_processing event
        end

        writable_sockets.each do |socket|
          connection = @connections[socket.fileno]
          user = UserStore.find_by_connection(connection)
          if user
            begin
              begin
                Timeout.timeout(TIMEOUT) do
                  Logger.info "Notifying user #{user.id} of messages: #{user.messages_to_send.strip}"
                  socket.write user.messages_to_send
                  Logger.info "User: Notfied of payload!"
                end
              rescue Timeout::Error
                raise NotificationError.new "Timed out!"
              rescue Errno::EPIPE
                raise NotificationError.new "Socket not conenected!"
              end
            rescue NotificationError => e
              Logger.warn "Notifying user failed due to: #{e}"
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

      if id = connection.read
        if user = UserStore.find(id)
          user.connection = connection
        else
          user = User.new(id, connection)
        end
        UserStore.add user
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
