require_relative '../spec_helper'

describe Wpxf::Utility::ReferenceInflater do
  describe '#new' do
    it 'raises an ArgumentError if the reference type isn\'t recognised' do
      expect { Wpxf::Utility::ReferenceInflater.new('invalid') }.to raise_error(ArgumentError)
    end
  end

  describe '#format_strings' do
    it 'returns a hash containing format strings for all currently supported reference types' do
      subject = Wpxf::Utility::ReferenceInflater.new('URL')
      expect(subject.format_strings.keys).to include('WPVDB', 'OSVDB', 'CVE', 'EDB', 'URL')
    end
  end

  describe '#inflate' do
    it 'inflates WPVDB references' do
      subject = Wpxf::Utility::ReferenceInflater.new('WPVDB')
      expect(subject.inflate(12)).to eq 'https://wpvulndb.com/vulnerabilities/12'
    end

    it 'inflates OSVDB references' do
      subject = Wpxf::Utility::ReferenceInflater.new('OSVDB')
      expect(subject.inflate(12)).to eq 'http://www.osvdb.org/12'
    end

    it 'inflates CVE references' do
      subject = Wpxf::Utility::ReferenceInflater.new('CVE')
      expect(subject.inflate(12)).to eq 'http://www.cvedetails.com/cve/CVE-12'
    end

    it 'inflates Exploit DB references' do
      subject = Wpxf::Utility::ReferenceInflater.new('EDB')
      expect(subject.inflate(12)).to eq 'https://www.exploit-db.com/exploits/12'
    end

    it 'inflates generic URL references' do
      subject = Wpxf::Utility::ReferenceInflater.new('URL')
      expect(subject.inflate('http://127.0.0.1/')).to eq 'http://127.0.0.1/'
    end
  end
end
