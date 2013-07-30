module FollowerMaze
  class User

    attr_reader :id, :connection, :follower_ids

    class NotificationError < StandardError; end

    def initialize id, connection
      @id = id.to_i
      @connection = connection
      @follower_ids = []
    end

    def notify payload
      Timeout.timeout(TIMEOUT) do
        connection.write payload
        Logger.info "User: Notfied of payload: #{payload}"
      end
    rescue Timeout::Error
      raise NotificationError.new
    rescue Errno::EPIPE
      raise NotificationError.new
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
