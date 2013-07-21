require 'socket'
require 'timeout'
require './lib/follower_maze/user'
require './lib/follower_maze/user_store'

module FollowerMaze
  class Server

    TIMEOUT = 2

    def initialize
      @event_server = TCPServer.new 9090
      @user_server = TCPServer.new 9099

      @connections = []
      @event_connection = nil
      @user_store = UserStore.new
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
        @user_store.add user
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

        to_user = @user_store.find(to_user_id) if to_user_id

        case type_key.downcase.to_sym
        when :f then follow(to_user, payload)
        when :u then unfollow
        when :b then broadcast(payload)
        when :p then private_message(to_user, payload)
        end
      end
    end

    def follow user, payload
      user.write payload
    end

    def unfollow
      # Do nothing
    end

    def broadcast payload
      @user_store.all.each do |user|
        user.write payload
      end
    end

    def private_message user, payload
      user.write payload
    end

  end
end
