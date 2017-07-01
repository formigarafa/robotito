require_relative './jabber_client'
require_relative './message_router'

module Robotito

  def self.jabber_client
    @jabber_client ||= JabberClient.new(
      :login => BOT_LOGIN,
      :password => BOT_PASSWORD,
      :server =>BOT_JABBER_HOST_SERVER,
      :port => BOT_JABBER_SERVER_PORT
    )
  end

  def self.router
    @router ||= MessageRouter.new
  end

  def self.run
    jabber_client.received_messages.each do |message|
      router.dispatch(message) do |response|
        jabber_client.deliver(message.from, response)
      end
    end
  end

  def self.stop
    jabber_client.stop
    puts "shuting down. bye!"
  end

end
