class JabberShell
  attr_accessor :messenger

  def connect
    puts "Connecting..."
    self.messenger = Jabber::Simple.new({:login => BOT_LOGIN, :password => BOT_PASSWORD, :server =>BOT_JABBER_HOST_SERVER, :port => BOT_JABBER_SERVER_PORT})
    puts "Connected"
  rescue
    puts "Ooops - Couldn't connect"
  end

  def connected?
    !! messenger
  end

  def run
    connect
    processing_loop if connected?
  end

  def processing_loop
    @sh = {}
    power_on

    while powered_on?
      messenger.received_messages do |message|
        process_message message
      end
      sleep 1
    end
  end

  def powered_on?
    @powered_on
  end

  def power_on
    @powered_on = true
  end

  def power_off
    @powered_on = false
  end

  def process_message(message)
    puts "Received #{message.body} from #{message.from}"
    master_name = message.from.to_s.split('/').first
    if message && ALLOWED_USERS.include?(master_name)
      process_command(message.body, master_name, message)
    else
      messenger.deliver(message.from, "I don't talk to strangers!\nUser not allowed: "+master_name)
    end
  end

  def process_command(command, master_name, message)
    if command == CLIENT_PASSPHRASE
      if @sh[master_name].nil?
        @sh[master_name] = Session::new
        messenger.deliver(message.from, "Now logged in!")
      else
        messenger.deliver(message.from, "Already logged in...")
      end
    elsif command == 'jabberhelp'
      messenger.deliver(message.from, 'jabberhelp: this message
      jabberw: users connected to a shell
      jabberpoweroff: power this robot off
      logmein: connect to shell
      exit: close the shell connection')
    elsif command == 'jabberw'
      messenger.deliver(message.from, @sh.keys.join(', '))
    elsif command == 'exit' and @sh[master_name] != nil
      @sh[master_name].close && @sh[master_name] = nil
      messenger.deliver(message.from, "Logged out...")
    elsif command == 'jabberpoweroff' and @sh[master_name].nil?
      messenger.deliver(message.from, "Power-off the bot!")
      power_off
    else
      if @sh[master_name]
        begin
          stdout, stderr = @sh[master_name].execute(command) if command
          messenger.deliver(message.from, "\n" + stdout.chomp) unless stdout.empty?
          messenger.deliver(message.from, "\n" + stderr.chomp) unless stderr.empty?
          messenger.deliver(message.from, @sh[master_name].execute('pwd')[0].chomp + "$>")
        rescue
          messenger.deliver(message.from, "Error: Shell aborted.\nCommand received:"+command)
          @sh[master_name].close && @sh[master_name] = nil
        end
      else
        messenger.deliver(message.from, 'Not Authenticated!')
      end
    end
  end
end
