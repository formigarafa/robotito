require 'session'
require 'shellwords'
require 'state_machines'
require_relative './otp_authenticator'

module Robotito
  class MessageProcessor
    attr_accessor :jid, :user_id, :apoptosis_mode

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

      event :logout do
        transition any => :identification
      end
    end

    def process(message)
      str = if first_word(message.body) == "exit"
        logout
        @bash && bash.close
        @bash = nil
        self.apoptosis_mode = true
        "Logged out"
      elsif first_word(message.body) == '#!w'
        Robotito.router.w
      else
        send("#{state_name}_command", message.body)
      end

      if block_given?
        # dbg_message = <<~MESSAGE
        #   Processor [#{self.object_id}]: state {#{self.state_name.inspect}}
        #   ====================
        #   #{str}
        # MESSAGE
        yield str
      end
    end

    private

    def authentication_command(message)
      password = first_word(message)
      if OtpAuthenticator.valid? user_id, password
        authenticate
        [
          "Authentication successfull.",
          bash.execute('pwd')[0].chomp + "$>",
        ].join("\n")
      else
        unidentify
        "Authentication failed."
      end
    end

    def bash
      @bash ||= Session::Bash::Login.new
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

    def shell_command(message)
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

  end
end
