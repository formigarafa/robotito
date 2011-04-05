class JabberShell
  attr_accessor :messenger
  
  def connect
    puts "Connecting..."
    begin
      self.messenger = Jabber::Simple.new({:login => BOT_LOGIN, :password => BOT_PASSWORD, :server =>BOT_JABBER_HOST_SERVER})
      puts "Connected"
    rescue Exception => e
      puts "Ooops - Couldn't connect"
    end
  end
  
  def connected?
    messenger ? true : false
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
    from_name = message.from.to_s.slice(0,message.from.to_s.index('/')).sub('/', '')
    if message && AllowsedUsers.include?(from_name)
      if message.body == CLIENT_PASSPHRASE
        if @sh[from_name].nil?
          @sh[from_name] = Session::new 
          messenger.deliver(message.from, "Now logged in!")
        else
          messenger.deliver(message.from, "Already logged in...")
        end
      elsif message.body == 'jabberhelp'
        messenger.deliver(message.from, 'jabberhelp: this message
        jabberw: users connected to a shell
        jabberpoweroff: power this robot off
        logmein: connect to shell
        exit: close the shell connection')
      elsif message.body == 'jabberw'
        messenger.deliver(message.from, @sh.keys.join(', '))
      elsif message.body == 'exit' and @sh[from_name] != nil
        @sh[from_name].close && @sh[from_name] = nil
        messenger.deliver(message.from, "Logged out...")
      elsif message.body == 'jabberpoweroff' and @sh[from_name].nil?
        messenger.deliver(message.from, "Power-off the bot!")
        power_off
      else
        if @sh[from_name]
          begin
            stdout, stderr = @sh[from_name].execute(message.body) if message.body
            messenger.deliver(message.from, "\n" + stdout.chomp) unless stdout.empty?
            messenger.deliver(message.from, "\n" + stderr.chomp) unless stderr.empty?
            messenger.deliver(message.from, @sh[from_name].execute('pwd')[0].chomp + "$>")
          rescue
            messenger.deliver(message.from, "Error: Shell aborted.\nCommand received:"+message.body)
            @sh[from_name].close && @sh[from_name] = nil
          end
        else
          messenger.deliver(message.from, 'Not Authenticated!')
        end
      end
    else
      messenger.deliver(message.from, "I don't talk to strangers!\nUser not allowed: "+from_name)
    end
  end
end