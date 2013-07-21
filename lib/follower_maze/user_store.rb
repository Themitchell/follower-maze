module FollowerMaze
  class UserStore

    def initialize
      @store = {}
    end

    def add user
      @store[user.id] = user
      Logger.info "Created user with id: #{user.id}"
      user
    end

    def find id
      user = @store[id.to_i]
      Logger.info "Found user with id: #{user.id}"
      user
    end

    def all
      users = @store.values
      Logger.info "Fetched all users from store"
      users
    end

    def destroy id
      @store.delete id.to_i
      Logger.info "Destroyed user with id: #{id.to_i}"
    end

  end
end
