module FollowerMaze
  class UserStore

    def initialize
      @store = {}
    end

    def add user
      @store[user.id] = user
      Logger.debug "Created user with id: #{user.id}" if user
      user
    end

    def find id
      user = @store[id.to_i]
      Logger.debug "Found user with id: #{user.id}"
      user
    end

    def all
      users = @store.values
      Logger.debug "Fetched #{users.size} users from store"
      users
    end

    def destroy id
      @store.delete id.try(:to_i)
      Logger.debug "Destroyed user with id: #{id.to_i}"
    end

  end
end
