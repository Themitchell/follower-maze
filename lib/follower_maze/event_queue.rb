module FollowerMaze
  class EventQueue

    attr_reader :events, :last_event_sequence_num

    def initialize
      @events = {}
      @last_event_sequence_num = 0
    end

    def add_event event
      Logger.debug "EventQueue: Adding Event #{event.sequence_num} to the queue"
      @events[event.sequence_num] = event
    end

    def process_events
      while has_events? && event = next_event
        begin
          event.process
        rescue FollowerMaze::Event::ProcessingError => e
          Logger.warn "Server: ProcessingError for event #{event.sequence_num}: #{e}"
        end
        complete_event_processing event
      end
    end

    private
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
