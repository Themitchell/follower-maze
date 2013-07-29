require 'socket'
require 'timeout'
require './lib/follower_maze/user_store'
require './lib/follower_maze/user'
require './lib/follower_maze/event'

module FollowerMaze
  class Server

    def initialize
      @event_server     = TCPServer.new 9090
      @event_connection = nil

      @user_server      = TCPServer.new 9099
      @connections      = []

      @events = {}
      @last_event_sequence_num = 0
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

        while @events.any?
          event = @events[@last_event_sequence_num += 1]

          if event.nil?
            @last_event_sequence_num -= 1
            break
          end

          begin
            event.process
          rescue FollowerMaze::User::NotificationError => e
            Logger.warn "Server: An error occurred processing #{event.kind} Event #{event.sequence_num}: #{e}"
            @last_event_sequence_num -= 1
            break
          else
            @events.delete event.sequence_num
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
        Timeout.timeout(TIMEOUT) do
          begin
            id = socket.gets
          rescue Errno::ECONNRESET => e
            Logger.warn "Server: An error occured creating a user: #{e}"
          end
        end
      rescue Timeout::Error
        Logger.error 'Server: Timed out reading message!'
      end

      if id
        begin
          user = UserStore.find id
        rescue FollowerMaze::UserStore::NotFoundError
          user = User.new id, socket
        end
        UserStore.add user
      end
    end

    def handle_message socket
      payload = nil
      begin
        Timeout.timeout(TIMEOUT) { payload = socket.gets }
      rescue Timeout::Error
        Logger.error 'Server: Timed out reading id!'
      end

      if payload
        Logger.debug "===> Server: Adding message #{payload.strip} to queue"
        event = Event.new payload
        @events[event.sequence_num] = event
      end
    end

  end
end
