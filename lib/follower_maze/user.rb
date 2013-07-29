require './lib/follower_maze/user_store'

module FollowerMaze
  class User

    attr_reader :id, :connection, :follower_ids

    def initialize id, connection
      @id = id.to_i
      @connection = connection
      @follower_ids = []
    end

    def write *args
      connection.write *args
    end

    def followers
      Logger.debug "User: Finding User #{id}'s followers #{@follower_ids.inspect}"
      @follower_ids.map { |id| UserStore.find id }
    end

    def add_follower user
      Logger.debug "User: Adding User #{user.id} to User #{id}'s followers"
      @follower_ids << user.id
    end

    def remove_follower user
      Logger.debug "User: Removing User #{user.id} from User #{id}'s followers"
      @follower_ids.delete user.id
    end

  end
end
