require_relative '../../spec_helper'

describe Wpxf::PortOption do
  let(:attrs) { { name: 'test', desc: 'desc' } }
  let(:subject) { Wpxf::PortOption.new(attrs) }

  describe '#normalize' do
    it 'returns an integer' do
      expect(subject.normalize('5')).to be_a Integer
    end
  end

  describe '#valid?' do
    it 'returns false if the value isn\'t numeric' do
      expect(subject.valid?('invalid')).to be false
    end

    it 'returns false if the value is less than 0' do
      expect(subject.valid?(-1)).to be false
    end

    it 'returns false if the value is greater than 65,535' do
      expect(subject.valid?(65_536)).to be false
    end

    it 'returns true if the value is beetween 0-65,535' do
      expect(subject.valid?(8080)).to be true
    end
  end
end
