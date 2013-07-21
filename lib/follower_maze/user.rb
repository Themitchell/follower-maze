module FollowerMaze
  class User

    attr_reader :id, :connection

    def initialize id, connection
      @id = id.to_i
      @connection = connection
    end

    def write *args
      connection.write *args
    end

  end
end
