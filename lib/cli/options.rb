module Cli
  # Methods for handling commands that interact with module options.
  module Options
    def unset(name)
      unless context
        print_bad 'No module loaded yet'
        return
      end

      if name.eql?('payload')
        context.module.payload = nil
      else
        context.module.unset_option(name)
      end

      print_good "Unset #{name}"
    end

    def load_payload(name)
      if context.module.to_s.split('::')[-2].eql? 'Auxiliary'
        print_warning 'Auxiliary modules do not use payloads'
        return
      end

      begin
        payload = context.load_payload(name)
        print_good "Loaded payload: #{payload}"
      rescue StandardError => e
        print_bad "Failed to load payload: #{e}"
        print_bad e.backtrace.join("\n\t")
      end

      # Set any globally set options.
      if payload
        @global_opts.each do |k, v|
          payload.set_option_value(k, v)
        end
      end

      refresh_autocomplete_options
    end

    def set_option_value(name, value, silent = false)
      res = context.module.set_option_value(name, value)

      return if silent

      if res == :not_found
        print_warning "\"#{name}\" is not a valid option"
      elsif res == :invalid
        print_bad "\"#{value}\" is not a valid value"
      else
        print_good "Set #{name} => #{res}"
      end
    end

    def gset(name, *args)
      if name.eql? 'payload'
        print_warning 'The payload cannot be globally set'
        return
      end

      value = args.join(' ')
      @global_opts[name] = value
      set_option_value(name, value, true) if context

      print_good "Globally set the value of #{name} to #{value}"
    end

    def gunset(name)
      @global_opts.delete(name)
      context.module.unset_option(name) if context
      print_good "Removed the global setting for #{name}"
    end

    def set(name, *args)
      value = args.join(' ')

      unless context
        print_warning 'No module loaded yet'
        return
      end

      begin
        if name.eql? 'payload'
          load_payload(value)
        else
          set_option_value(name, value)
        end
      rescue StandardError => e
        print_bad "Failed to set #{name}: #{e}"
        print_bad e.backtrace.join("\n\t")
      end
    end
  end
end
