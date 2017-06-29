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
      event :noop do
        transition all => same
      end
    end

    def process(message)
      command_data = parse_command(message.body)
      str = if ! command_data[:valid]
        "command invalid: #{command_data.inspect}"
      elsif command_data[:internal]
        send command_data[:command]
      else
        "not Implemented"
      end
      if block_given?
        yield <<~MESSAGE
          Processor [#{self.object_id}]: state {#{self.state_name.inspect}}
          ====================
          #{str}
        MESSAGE
      end
    end

    private

    def parse_command(message)
      first_line = message.lines.map(&:strip).reject(&:empty?).first || '#!noop'
      command = (first_line[2..-1].split(" ").first || 'noop').to_sym
      internal = first_line[0..1] == '#!'
      {
        internal: internal,
        command: command,
        valid: !internal || state_events.include?(command),
      }
    end
  end
end
