module Wpxf
  # An event emitter that allows one or more subscribers.
  class EventEmitter
    def initialize
      @subscribers = []
    end

    # Subscribe to the events emitted by this {EventEmitter}.
    # @param subscriber [Object] the event subscriber.
    def subscribe(subscriber)
      @subscribers.push(subscriber)
    end

    # Unsubscribe from the events emitted by this {EventEmitter}.
    # @param subscriber [Object] the event subscriber.
    def unsubscribe(subscriber)
      @subscribers -= [subscriber]
    end

    # Emit an event to be handled by each subscriber.
    # @param event [Object] the event object to emit.
    def emit(event)
      @subscribers.each do |s|
        s.on_event_emitted(event) if s.respond_to? 'on_event_emitted'
      end
    end
  end
end
