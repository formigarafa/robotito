require 'state_machines'
require 'shellwords'

module Robotito
  class MessageProcessor
    attr_accessor :jid, :user_id

    def initialize(jid)
      self.jid = jid
      super()
    end

    state_machine :state, initial: :identification do
      event :identify do
        transition :identification => :authentication
      end

      event :unidentify do
        transition :authentication => :identification
      end

      event :authenticate do
        transition :authentication => :shell
      end

      event :work do
        transition :shell => :busy
      end

      event :rest do
        transition :busy => :shell
      end

      event :logout do
        transition :shell => :identification
      end
    end

    def process(message)
      # command_data = parse_command(message.body)
      str = send("#{state_name}_command", message.body)
      if block_given?
        yield <<~MESSAGE
          Processor [#{self.object_id}]: state {#{self.state_name.inspect}}
          ====================
          #{str}
        MESSAGE
      end
    end

    private

    def sanitize_message(message)
      # first_line = message.lines.map(&:strip).reject(&:empty?).first
      # command = (first_line[2..-1].split(" ").first || 'noop').to_sym
      # internal = first_line[0..1] == '#!'
      # {
      #   internal: internal,
      #   command: command,
      #   valid: !internal || state_events.include?(command),
      # }
    end

    def first_word(message)
      message.lines.map(&:strip).reject(&:empty?).first
    end

    def identification_command(message)
      id = first_word(message)
      id_found, _ = PASSWD.find{|k, v| k.to_s == id}
      if id_found
        self.user_id = id_found
        identify
        "Welcome, #{user_id}. Please send authentication."
      else
        "Unknown User: #{id}"
      end
    end

    def authentication_command(message)
      password = first_word(message)
      if password == PASSWD[user_id]
        authenticate
        "Authentication successfull."
      else
        unidentify
        "Authentication failed."
      end
    end

    def bash
      @bash ||= Session::new
    end

    def shell_command(message)
      if first_word(message) == "exit"
        logout
        bash.close
        @bash = nil
        return "Logged out"
      end

      if shell_command_valid?(message)
        responses = bash.execute(message)
        responses << bash.execute('pwd')[0].chomp + "$>"
        responses.reject(&:empty?).join("\n")
      else
        "Invalid command: (#{message})"
      end
    end

    def shell_command_valid?(cmd)
      parts = Shellwords.shellsplit(cmd)
      parts.instance_of?(Array) && ! parts.size.zero?
    rescue ArgumentError
      return false
    end

    def busy_command(message)
      "busy #{message}"
    end

  end
end
