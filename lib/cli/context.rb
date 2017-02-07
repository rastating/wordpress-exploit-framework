module Cli
  # A context which modules will be used in.
  class Context
    def class_name(path_name)
      return path_name if path_name !~ /_/ && path_name =~ /[A-Z]+.*/
      path_name.split('_').map(&:capitalize).join
    end

    def verbose?
      self.module.normalized_option_value('verbose')
    end

    def load_module(path)
      @module = Wpxf.load_module(path)
      @module_path = path
      @module
    end

    def reload
      if @module_path =~ /^exploit\//i
        load("#{@module_path.sub('exploit/', 'exploits/')}.rb")
      else
        load("#{@module_path}.rb")
      end

      load_module(@module_path)
    end

    def load_payload(name)
      self.module.payload = Wpxf::Payloads.load_payload(name)
      self.module.payload.check(self.module)
      self.module.payload
    end

    attr_reader :module_path
    attr_reader :module
  end
end
