require 'socket'
require 'timeout'
require './lib/follower_maze/user_store'
require './lib/follower_maze/user'
require './lib/follower_maze/event'

module FollowerMaze
  class Server

    TIMEOUT = 2

    def initialize
      @event_server     = TCPServer.new 9090
      @event_connection = nil

      @user_server      = TCPServer.new 9099
      @connections      = []

      @events = {}
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
        Timeout.timeout(TIMEOUT) { id = socket.gets }
      rescue Timeout::Error
        Logger.error 'Server: Timed out reading message!'
      end

      if id
        user = User.new id, socket
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
        Logger.debug "Server: Handling message #{payload.strip}"
        event = Event.new payload
        @events[event.sequence_num] = event

        send(event.kind, event)
      end
    end

    def follow event
      return nil unless event.from_user && event.to_user
      event.to_user.add_follower event.from_user
      Logger.debug "Server: User #{event.from_user.id} followed User #{event.to_user.id}"
      event.to_user.write event.payload
    end

    def unfollow event
      return nil unless event.from_user && event.to_user
      event.to_user.remove_follower event.from_user
      Logger.debug "Server: User #{event.from_user.id} unfollowed User #{event.to_user.id}"
    end

    def broadcast event
      users = UserStore.all
      Logger.debug "Server: #{users.size} Users available to broadcast"
      users.each do |user|
        user.write event.payload
      end
    end

    def private_message event
      return nil unless event.to_user
      event.to_user.write event.payload if event.to_user
    end

    def status_update event
      return nil unless event.from_user
      followers = event.from_user.followers
      Logger.debug "Server: User #{event.from_user.id} sending a status update to #{followers.count} followers..."
      followers.each do |user|
        Logger.debug "Server: ...User #{event.from_user.id} sending a status update to User: #{user.id}"
        user.write event.payload
      end
    end

  end
end
