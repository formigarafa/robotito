#!/usr/bin/env ruby

# Jabber-SH — SH console via XMPP/Jabber (GTalk)
#
# Jabber-SH allows you to administrate a remote computer via a command line 
# through a Jabber client. It’s like SSH via GoogleTalk! :)
# This is just a hack but it might be usefull sometime to run basic commands
# on a machine that is not accessible via ssh.
#
# Philippe Creux. pcreux/AT/gmail/DOT/com

require 'config'
require 'rubygems'
require 'xmpp4r-simple'
require 'session'

puts "Connecting"
if messenger = Jabber::Simple.new({:login => BOT_LOGIN, :password => BOT_PASSWORD, :server =>BOT_JABBER_HOST_SERVER})
  puts "Connected"
else
  puts "Ooops - Can't connect"
end
#exit
@sh = {}

while true
  messenger.received_messages do |msg|  
    puts "Received #{msg.body} from #{msg.from}"
    from_name = msg.from.to_s.slice(0,msg.from.to_s.index('/')).sub('/', '')
    if msg && allowed_users.include?(from_name)
      if msg.body == CLIENT_PASSPHRASE
        if @sh[from_name] == nil
          @sh[from_name] = Session::new 
          messenger.deliver(msg.from, "Now logged in!")
        else
          messenger.deliver(msg.from, "Already logged in...")
        end
      elsif msg.body == 'exit' and @sh[from_name] != nil
        @sh[from_name].close && @sh[from_name] = nil
        messenger.deliver(msg.from, "Logged out...")
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
