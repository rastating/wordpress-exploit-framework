# Provides common functionality for socket based payloads.
module Wpxf::Payloads::SocketHelper
  def start_socket_io_loop(socket, event_emitter)
    read_thread = Thread.new { start_socket_read_loop(socket) }
    execute_queued_commands(socket, event_emitter)
    start_socket_write_loop(socket, read_thread)
  rescue SignalException
    puts
    event_emitter.emit_warning 'Caught kill signal', true
  rescue StandardError => e
    puts
    event_emitter.emit_error "Error encountered: #{e}"
  end

  def execute_queued_commands(socket, event_emitter)
    queued_commands.each do |cmd|
      socket.puts cmd
      event_emitter.emit_success "Executed: #{cmd}"
    end

    puts
  end

  def start_socket_write_loop(socket, read_thread)
    loop do
      input = STDIN.gets
      if input =~ /^(quit|exit)$/i
        read_thread.exit
        break
      else
        socket.puts input
      end
    end
  end

  def start_socket_read_loop(socket)
    loop do
      begin
        print socket.read_nonblock(1024)
      rescue IO::WaitReadable
        retry
      rescue StandardError => e
        raise 'Connection lost' if e.is_a? EOFError
        puts "SOCKET ERROR: #{e}"
      end
    end
  end
end
