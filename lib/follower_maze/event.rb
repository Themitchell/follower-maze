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
      @from_user ||= UserStore.find from_user_id
    end

    def to_user
      @to_user ||= UserStore.find to_user_id
    end

  end
end
