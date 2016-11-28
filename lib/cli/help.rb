module Cli
  # Methods for handling commands that provide the user with help info.
  module Help
    def print_options(mod)
      print_std 'Module options:'
      puts
      indent_cursor do
        print_options_table(mod, module_options(false))
      end
    end

    def print_payload_options(payload)
      print_std 'Payload options:'
      puts
      indent_cursor do
        print_options_table(payload, payload.options)
      end
    end

    def show_options
      return unless module_loaded?

      print_options(context.module)
      return unless context.module.payload

      puts
      print_payload_options(context.module.payload)
    end

    def print_options_table(parent, opts)
      data = empty_option_table_data
      opts.each do |opt|
        data.push(option_table_row(parent, opt))
      end

      print_table(data)
    end

    def print_advanced_option(opt)
      print_std "Name: #{opt.name}"
      print_std "Current setting: #{context.module.normalized_option_value(opt.name)}"
      print_std "Required: #{opt.required?}"
      print_std "Description: #{opt.desc}"
    end

    def show_advanced_options
      return unless module_loaded?

      module_options(true).each do |opt|
        print_advanced_option(opt)
        puts
      end
    end

    def help
      commands_file = Wpxf::DataFile.new('json', 'commands.json')
      data = JSON.parse(commands_file.content)['data']
      data.unshift('cmd' => 'Command', 'desc' => 'Description')
      indent_cursor 2 do
        print_table data
      end
    end

    def show_exploits
      results = search_modules(['exploit/'])
      print_good "#{results.length} Exploits"
      print_module_table results
    end

    def show_auxiliary
      results = search_modules(['auxiliary/'])
      print_good "#{results.length} Auxiliary Modules"
      print_module_table results
    end

    def show(target)
      handlers = {
        'options' => 'show_options',
        'advanced' => 'show_advanced_options',
        'exploits' => 'show_exploits',
        'auxiliary' => 'show_auxiliary'
      }

      if handlers[target]
        send(handlers[target])
      else
        print_bad("\"#{target}\" is not a valid argument")
      end
    end

    private

    def module_options(advanced)
      return [] unless context
      opts = context.module.options.select { |o| o.advanced? == advanced }
      opts.sort_by(&:name)
    end

    def empty_option_table_data
      [{
        name: 'Name',
        value: 'Current Setting',
        req: 'Required',
        desc: 'Description'
      }]
    end

    def option_table_row(parent, opt)
      {
        name: opt.name,
        value: parent.normalized_option_value(opt.name),
        req: opt.required?,
        desc: opt.desc
      }
    end
  end
end
