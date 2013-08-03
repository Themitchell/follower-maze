module FollowerMaze
  class EventQueue

    attr_reader :events, :last_event_sequence_num

    def initialize
      @events = {}
      @last_event_sequence_num = 0
    end

    def add_event event
      Logger.debug "EventQueue: Adding Event #{event_sequence_num} to the queue"
      @events[event.sequence_num] = event
    end

    def complete_event_processing event
      @last_event_sequence_num = event.sequence_num
      @events.delete event.sequence_num
    end

    def next_event
      event = @events[@last_event_sequence_num + 1]
    end

    def has_events?
      @events.any?
    end
  end
end
