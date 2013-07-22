require 'socket'
require 'timeout'
require './lib/follower_maze/user_store'
require './lib/follower_maze/user'

module FollowerMaze
  class Server

    TIMEOUT = 2

    def initialize
      @event_server = TCPServer.new 9090
      @user_server = TCPServer.new 9099

      @connections = []
      @event_connection = nil
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
        Logger.error 'Timed out reading message!'
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
        Logger.error 'Timed out reading id!'
      end

      if payload
        Logger.debug "Handling message: #{payload.strip}"
        sequence_num, type_key, from_user_id, to_user_id = payload.strip.split('|')

        type      = type_key.downcase.to_sym
        from_user = UserStore.find(from_user_id)  if from_user_id
        to_user   = UserStore.find(to_user_id)    if to_user_id

        case type
        when :f then follow(from_user, to_user, payload)
        when :u then unfollow(from_user, to_user)
        when :b then broadcast(payload)
        when :p then private_message(from_user, to_user, payload)
        end
      end
    end

    def follow from_user, to_user, payload
      to_user.add_follower from_user
      Logger.debug "User: #{from_user.id} followed User: #{to_user.id}"
      to_user.write payload
    end

    def unfollow from_user, to_user
      to_user.remove_follower from_user
      Logger.debug "Server: User #{from_user.id} unfollowed User #{to_user.id}"
    end

    def broadcast payload
      users = UserStore.all
      Logger.debug "#{users.size} users available to broadcast"
      users.each do |user|
        user.write payload
      end
    end

    def private_message from_user, to_user, payload
      to_user.write payload
    end

  end
end
