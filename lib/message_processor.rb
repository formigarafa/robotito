require 'state_machines'

module Robotito
  class MessageProcessor
    attr_accessor :jid

    def initialize(jid)
      self.jid = jid
      super()
    end

    state_machine :state, initial: :waiting_for_identification do
      event :identify do
        transition :waiting_for_identification => :waiting_for_authentication
      end

      event :authenticate do
        transition :waiting_for_authentication => :idle
      end

      event :work do
        transition :idle => :working
      end

      event :cancel do
        transition :idle => same, :working => :idle
      end

      event :logout do
        transition :idle => :waiting_for_identification
      end
    end

    def process(message)
      if respond_to?(message.body.strip)
        send message.body.strip
      end
      if block_given?
        yield <<~MESSAGE
          Processor [#{self.object_id}]: state {#{self.state_name.inspect}}
        MESSAGE
      end
    end
  end
end
