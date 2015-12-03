require_relative '../spec_helper'

describe Wpxf::Versioning::OSVersions do
  let(:subject) do
    (Class.new { include Wpxf::Versioning::OSVersions }).new
  end

  describe '#random_nt_version' do
    it 'returns a String' do
      expect(subject.random_nt_version).to be_a String
    end

    it 'returns a string in the correct format' do
      pattern = /^[5-6]\.[0-1]$/
      expect(subject.random_nt_version).to match pattern
    end
  end

  describe '#random_osx_version' do
    it 'returns a String' do
      expect(subject.random_osx_version).to be_a String
    end

    it 'returns a string in the correct format' do
      pattern = /^10_[5-7]_[0-9]$/
      expect(subject.random_osx_version).to match pattern
    end
  end
end
