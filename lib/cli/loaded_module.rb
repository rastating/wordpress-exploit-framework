module Cli
  # Methods for handling commands that interact with the currently loaded module.
  module LoadedModule
    include Cli::ModuleInfo

    def module_loaded?
      print_warning 'No module loaded' unless context
      !context.nil?
    end

    def module_can_execute?
      can_execute = context.module.can_execute?
      unless can_execute
        opts = context.module.missing_options.join(', ')
        print_bad "One or more required options not set: #{opts}"
      end
      can_execute
    end

    def payload_prepared?
      failed = context.module.payload && !context.module.payload.prepare(context.module)
      print_bad 'Failed to prepare the payload' if failed
      !failed
    end

    def execute_module
      mod = context.module
      mod.run && (!mod.payload || mod.payload.post_exploit(mod))
    rescue StandardError => e
      print_bad "Uncaught error: #{e}"
      print_bad e.backtrace.join("\n\t")
      false
    end

    def run
      return unless module_loaded? && module_can_execute? && payload_prepared?

      if execute_module
        print_good 'Execution finished successfully'
      else
        print_bad 'Execution failed'
      end

      context.module.cleanup
    end

    def check
      return unless module_loaded? && module_can_execute?
      state = context.module.check

      if state == :vulnerable
        print_warning 'Target appears to be vulnerable'
      elsif state == :unknown
        print_bad 'Could not determine if the target is vulnerable'
      else
        print_good 'Target appears to be safe'
      end
    end
  end
end
