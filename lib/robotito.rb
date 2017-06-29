module Robotito

  def self.jabber_client
    @jabber_client ||= JabberClient.new(
      :login => BOT_LOGIN,
      :password => BOT_PASSWORD,
      :server =>BOT_JABBER_HOST_SERVER,
      :port => BOT_JABBER_SERVER_PORT
    )
  end

  def self.run
    jabber_client.received_messages.each do |message|
      puts "Received #{message.body} from #{message.from}"
    end
  end

  def self.stop
    jabber_client.stop
    puts "shuting down. bye!"
  end

end
