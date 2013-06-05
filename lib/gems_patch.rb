module Jabber
  class Simple

    def initialize(connection_info, status = nil, status_message = "Available")
      @jid = connection_info[:login]
      @password = connection_info[:password]
      @server = connection_info[:server]
      @port = connection_info[:port] || 5222
      @disconnected = false
      status(status, status_message)
      start_deferred_delivery_thread
    end
    
    def connect!
      raise ConnectionError, "Connections are disabled - use Jabber::Simple::force_connect() to reconnect." if @disconnected
      # Pre-connect
      @connect_mutex ||= Mutex.new

      # don't try to connect if another thread is already connecting.
      return if @connect_mutex.locked?

      @connect_mutex.lock
      disconnect!(false) if connected?

      # Connect
      jid = JID.new(@jid)
      my_client = Client.new(@jid)
      my_client.connect @server, @port
      my_client.auth(@password)
      self.client = my_client

      # Post-connect
      register_default_callbacks
      status(@presence, @status_message)
      @connect_mutex.unlock
    end
  end
end
