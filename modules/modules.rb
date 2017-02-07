module Wpxf
  def self.build_module_list(namespace, id_prefix = '')
    modules = namespace.constants.select do |c|
      namespace.const_get(c).is_a? Class
    end

    modules.map do |m|
      klass = namespace.const_get(m)
      filename = klass.new.method(:initialize).source_location[0]
      {
        class: klass,
        name: "#{id_prefix}#{File.basename(filename, '.rb')}"
      }
    end
  end

  def self.load_module(name)
    match = name.match(/(auxiliary|exploit)\/(.+)/i)
    raise 'Invalid module path' unless match

    type = match.captures[0]
    list = type == 'auxiliary' ? Wpxf::Auxiliary.module_list : Wpxf::Exploit.module_list

    mod = list.find { |p| p[:name] == name }
    raise "\"#{name}\" is not a valid module" if mod.nil?
    mod[:class].new
  end

  module Auxiliary
    def self.module_list
      @@modules ||= Wpxf.build_module_list(Wpxf::Auxiliary, 'auxiliary/')
    end
  end

  module Exploit
    def self.module_list
      @@modules ||= Wpxf.build_module_list(Wpxf::Exploit, 'exploit/')
    end
  end

  module Payloads
    def self.payload_count
      payloads = Wpxf::Payloads.constants.select do |c|
        Wpxf::Payloads.const_get(c).is_a? Class
      end

      payloads.size
    end

    def self.payload_list
      @@payloads ||= Wpxf.build_module_list(Wpxf::Payloads)
    end

    def self.load_payload(name)
      payload = payload_list.find { |p| p[:name] == name }
      raise "\"#{name}\" is not a valid payload" if payload.nil?
      payload[:class].new
    end
  end
end

require_rel 'auxiliary'
require_rel 'exploits'
require_rel '../payloads'
