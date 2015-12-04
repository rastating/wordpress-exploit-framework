require_relative '../../spec_helper'

describe Wpxf::EnumOption do
  let(:attrs) { { name: 'test', desc: 'desc', enums: [1, 2, 3] } }
  let(:subject) { Wpxf::EnumOption.new(attrs) }

  describe '#valid?' do
    it 'returns false if the value is not in the valid enum list' do
      expect(subject.valid?(10)).to be false
    end

    it 'returns true if the value is in the valid enum list' do
      [1, 2, 3].each do |v|
        expect(subject.valid?(v)).to be true
      end
    end
  end
end
