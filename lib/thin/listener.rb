require "socket"

module Thin
  class Listener
    attr_reader :address
    
    attr_reader :port
    
    def initialize(address, port)
      @address = address
      @port = port
    end
    
    def socket
      @socket ||= TCPServer.new(*[address, port].compact)
    end
    
    def reuse_address=(value)
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, value)
    end
    
    def tcp_no_delay=(value)
      socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, value)
    end
    
    def listen(backlog)
      socket.listen(backlog)
    end
    
    def close
      socket.close if @socket
    end
    
    def to_s
      (@address || "*") + ":#{@port}"
    end
    
    def self.parse(address)
      case address
      when Integer
        new nil, address
      when /\A(?:\*:)?(\d+)\z/ # *:port or "port"
        new nil, $1.to_i
      when /\A((?:\d{1,3}\.){3}\d{1,3}):(\d+)\z/ # 0.0.0.0:port
        new $1, $2.to_i
      else
        raise ArgumentError, "Invalid address #{address.inspect}. " +
                             "Accepted formats are: 3000, *:3000 or 0.0.0.0:3000"
      end
    end
  end
end