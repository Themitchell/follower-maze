require 'singleton'

module FollowerMaze
  class UserStore

    @store = {}

    class NotFoundError < StandardError; end

    class << self
      def add user
        @store[user.id] = user
        Logger.debug "UserStore: Created user with id: #{user.id}" if user
        user
      end

      def create_or_update id, connection
        if user = find(id)
          user.connection = connection
          user
        else
          user = User.new id, connection
          add(user)
          user
        end
      end

      def find id
        user = @store[id.to_i]
        return nil unless user
        Logger.debug "UserStore: Found user with id: #{user.id}"
        user
      end

      def find! id
        user = find id
        raise NotFoundError.new unless user
        user
      end

      def find_by_connection connection
        user = @store.values.find { |user| user.connection.fileno == connection.fileno }
        return nil unless user
        Logger.debug "UserStore: Found user with id: #{user.id}"
        user
      end

      def all
        users = @store.values
        Logger.debug "UserStore: Fetched #{users.size} users from store"
        users
      end

      def destroy user
        @store.delete user.id
        Logger.debug "UserStore: Destroyed user with id: #{user.id}"
        return nil
      end

      def destroy_all
        @store = {}
        Logger.debug "UserStore: Destroyed everything!!!!!!"
      end
    end
  end
end
