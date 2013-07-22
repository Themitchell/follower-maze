require 'singleton'

module FollowerMaze
  class UserStore

    @store = {}

    class << self
      def add user
        @store[user.id] = user
        Logger.debug "UserStore: Created user with id: #{user.id}" if user
        user
      end

      def find id
        user = @store[id.to_i]
        Logger.debug "UserStore: Found user with id: #{user.id}" if user
        user
      end

      def all
        users = @store.values
        Logger.debug "UserStore: Fetched #{users.size} users from store"
        users
      end

      def destroy id
        @store.delete id.try(:to_i)
        Logger.debug "UserStore: Destroyed user with id: #{id.try(:to_i)}"
      end

      def destroy_all
        @store = {}
        Logger.debug "UserStore: Destroyed everything!!!!!!"
      end
    end
  end
end
