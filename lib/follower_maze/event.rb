module FollowerMaze
  class Event

    attr_reader :sequence_num, :kind_key, :from_user_id, :to_user_id, :payload

    def initialize payload
      @payload = payload
      payload_parts = @payload.strip.split('|')
      @sequence_num = payload_parts[0].to_i if payload_parts[0]
      @kind_key     = payload_parts[1].downcase.to_sym if payload_parts[1]
      @from_user_id = payload_parts[2].to_i if payload_parts[2]
      @to_user_id   = payload_parts[3].to_i if payload_parts[3]
    end

    def kind
      case @kind_key
      when :f then :follow
      when :u then :unfollow
      when :b then :broadcast
      when :p then :private_message
      when :s then :status_update
      end
    end

    def from_user
      UserStore.find from_user_id
    end

    def to_user
      UserStore.find to_user_id
    end

    def process
      Logger.info "Processing #{kind} Event #{sequence_num} with payload #{payload.strip}"

      begin
        case kind
        when :follow
          to_user.add_follower from_user
          to_user.notify payload
        when :unfollow
          to_user.remove_follower from_user
        when :broadcast
          UserStore.all.each do |user|
            user.notify payload
          end
        when :private_message
          to_user.notify payload
        when :status_update
          from_user.followers.each do |user|
            user.notify payload
          end
        end

      rescue FollowerMaze::UserStore::NotFoundError => e
        Logger.warn "Event: Cancelled Event #{sequence_num} because no user was found: #{e}"
      end

    end
  end
end
