module FollowerMaze
  class User

    attr_accessor :connection
    attr_reader :id, :follower_ids, :messages_to_send

    def initialize id, connection
      @id = id.to_i
      @connection = connection
      @follower_ids = []
      @messages_to_send = ""
    end

    def notify payload
      @messages_to_send << payload
    end

    def followers
      Logger.debug "User: Finding User #{id}'s followers #{@follower_ids.inspect}"
      @follower_ids.map { |id| UserStore.find id }
    end

    def add_follower follower_id
      Logger.debug "User: Adding User #{follower_id} to User #{id}'s followers"
      @follower_ids << follower_id
    end

    def remove_follower follower_id
      Logger.debug "User: Removing User #{follower_id} from User #{id}'s followers"
      @follower_ids.delete follower_id
    end

    def reset_messages!
      @messages_to_send = ""
    end

  end
end
