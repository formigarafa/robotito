module Robotito
  class JabberClient
    attr_accessor :config, :enabled

    def initialize(config = {})
      self.config = config
    end

    def cli
      @cli ||= Jabber::Simple.new({:login => BOT_LOGIN, :password => BOT_PASSWORD, :server =>BOT_JABBER_HOST_SERVER, :port => BOT_JABBER_SERVER_PORT})
    end

    def deliver(recipient_jid, message)
      cli.deliver(recipient_jid, message)
    end

    def received_messages
      self.enabled = true
      puts "Connecting..."
      self.enabled = true
      Enumerator.new do |yielder|
        puts "Connected."
        loop do
          cli.received_messages do |message|
            break if ! enabled
            puts ""
            yielder << message
          end
          break if ! enabled
          sleep 0.1
          putc '.'
        end
      end
    end

    def stop
      self.enabled = false
    end

  end
end
