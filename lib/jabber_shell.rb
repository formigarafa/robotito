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
    poweron = true

    while poweron
      messenger.received_messages do |msg|  
        puts "Received #{msg.body} from #{msg.from}"
        from_name = msg.from.to_s.slice(0,msg.from.to_s.index('/')).sub('/', '')
        if msg && AllowsedUsers.include?(from_name)
          if msg.body == CLIENT_PASSPHRASE
            if @sh[from_name].nil?
              @sh[from_name] = Session::new 
              messenger.deliver(msg.from, "Now logged in!")
            else
              messenger.deliver(msg.from, "Already logged in...")
            end
          elsif msg.body == 'jabberhelp'
            messenger.deliver(msg.from, 'jabberhelp: this message
            jabberw: users connected to a shell
            jabberpoweroff: power this robot off
            logmein: connect to shell
            exit: close the shell connection')
          elsif msg.body == 'jabberw'
            messenger.deliver(msg.from, @sh.keys.join(', '))
          elsif msg.body == 'exit' and @sh[from_name] != nil
            @sh[from_name].close && @sh[from_name] = nil
            messenger.deliver(msg.from, "Logged out...")
          elsif msg.body == 'jabberpoweroff' and @sh[from_name].nil?
            messenger.deliver(msg.from, "Power-off the bot!")
            poweron = false
          else
            if @sh[from_name]
              begin
                stdout, stderr = @sh[from_name].execute(msg.body) if msg.body
                messenger.deliver(msg.from, "\n" + stdout.chomp) unless stdout.empty?
                messenger.deliver(msg.from, "\n" + stderr.chomp) unless stderr.empty?
                messenger.deliver(msg.from, @sh[from_name].execute('pwd')[0].chomp + "$>")
              rescue
                messenger.deliver(msg.from, "Error: Shell aborted.\nCommand received:"+msg.body)
                @sh[from_name].close && @sh[from_name] = nil
              end
            else
              messenger.deliver(msg.from, 'Not Authenticated!')
            end
          end
        else
          messenger.deliver(msg.from, "I don't talk to strangers!\nUser not allowed: "+from_name)
        end
      end  
      sleep 1  
    end
  end
end