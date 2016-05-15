module Wpxf
  # The base class for all modules.
  class Module
    include Wpxf::ModuleInfo
    include Wpxf::OutputEmitters
    include Wpxf::Options
    include Wpxf::Net::HttpClient
    include Wpxf::WordPress::Fingerprint
    include Wpxf::WordPress::Login
    include Wpxf::WordPress::Options
    include Wpxf::WordPress::Urls
    include Wpxf::ModuleAuthentication

    def initialize
      super

      register_option(
        BooleanOption.new(
          name: 'verbose',
          desc: 'Enable verbose output',
          required: true,
          default: false
        )
      )

      register_advanced_options([
        BooleanOption.new(
          name: 'check_wordpress_and_online',
          desc: 'Check that the target is running WordPress and is online',
          required: true,
          default: true
        )
      ])

      self.event_emitter = EventEmitter.new
    end

    # @return [Boolean] true if all the required options are set.
    def can_execute?
      all_options_valid? && (
        aux_module? || (payload && payload.all_options_valid?)
      )
    end

    # @return [Boolean] true if the target is running WordPress.
    def check_wordpress_and_online
      unless wordpress_and_online?
        emit_error "#{full_uri} does not appear to be running WordPress"
        return false
      end

      true
    end

    # @return [Array] an array of missing option names that are required.
    def missing_options
      opts = super
      opts.push('payload') if exploit_module? && !payload

      if payload
        payload_opts = payload.missing_options
        opts = [*opts, *payload_opts] unless payload_opts.empty?
      end

      opts
    end

    # Set the value of a module option.
    # @param name the name of the option to set.
    # @param value the value to use.
    # @return [String, Symbol] the normalized value, :invalid if the
    #   specified value is invalid or :not_found if the name is invalid.
    def set_option_value(name, value)
      res = super(name, value)

      if payload
        return payload.set_option_value(name, value) if res == :not_found
        payload.set_option_value(name, value)
      end

      res
    end

    # Unset an option or reset it back to its default value.
    # @param name [String] the name of the option to unset.
    def unset_option(name)
      super(name)
      payload.unset_option(name) if payload
    end

    # Run the module.
    # @return [Boolean] true if successful.
    def run
      if normalized_option_value('check_wordpress_and_online')
        return false unless check_wordpress_and_online
      end

      if requires_authentication
        @session_cookie = authenticate_with_wordpress(datastore['username'], datastore['password'])
        return false unless @session_cookie
      end

      true
    end

    # Cleanup any allocated resource to the module.
    def cleanup
      payload.cleanup if payload
    end

    # Check if the target is vulnerable.
    # @return [Symbol] :unknown, :vulnerable or :safe.
    def check
      :unknown
    end

    # @return [Boolean] true if the module is an auxiliary module.
    def aux_module?
      to_s.split('::')[-2].eql? 'Auxiliary'
    end

    # @return [Boolean] true if the module is an exploit module.
    def exploit_module?
      to_s.split('::')[-2].eql? 'Exploit'
    end

    # @return [Payload] the {Payload} to use with the current module.
    attr_accessor :payload

    # @return [EventEmitter] the {EventEmitter} for the module's events.
    attr_accessor :event_emitter

    # @return [String, nil] the current session cookie, if authenticated with the target.
    attr_reader :session_cookie
  end
end
