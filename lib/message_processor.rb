module Robotito
  class MessageProcessor
    attr_accessor :jid

    def initialize(jid)
      self.jid = jid
    end

    def process(message)
      if block_given?
        yield <<~MESSAGE
          Processor [#{self.object_id}] for #{jid.to_s}, process:\n#{message.body}
          Received #{message.body} from #{message.from}
        MESSAGE
      end
    end
  end
end
