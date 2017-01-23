require_relative 'spec_helper'
require 'modules'

describe Wpxf do
  describe '.build_module_list' do
    it 'builds an array of hashes containing the modules for the specified namespace' do
      result = Wpxf.build_module_list(Wpxf::Exploit, 'exploit/')
      expect(result[0]).to include(:class, :name)

      mod = result.find { |m| m[:name] == 'exploit/admin_shell_upload' }
      expect(mod).to_not be_nil
      expect(mod[:class]).to be Wpxf::Exploit::AdminShellUpload
    end
  end
end

describe 'Wpxf::Auxiliary' do
  describe '.module_list' do
    it 'builds an array of hashes containing the auxiliary modules' do
      list = Wpxf::Auxiliary.module_list
      expect(list).to_not be_nil
      expect(list[0]).to include(:class, :name)
    end
  end
end

describe 'Wpxf::Exploit' do
  describe '.module_list' do
    it 'builds an array of hashes containing the exploit modules' do
      list = Wpxf::Exploit.module_list
      expect(list).to_not be_nil
      expect(list[0]).to include(:class, :name)
    end
  end
end

describe 'Wpxf::Payloads' do
  describe '.payload_list' do
    it 'builds an array of hashes containing the module payloads' do
      list = Wpxf::Payloads.payload_list
      expect(list).to_not be_nil
      expect(list[0]).to include(:class, :name)
    end
  end
end
