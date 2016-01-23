require_relative '../spec_helper'

describe Wpxf::EventEmitter do
  let(:subject) { Wpxf::EventEmitter.new }

  describe '#subscribe' do
    it 'adds the specified object to the subscriber list' do
      subscriber = Object.new
      expect(subject.subscribe(subscriber)).to eq [subscriber]
    end
  end

  describe '#unsubscribe' do
    it 'removes the specified object from the subscriber list' do
      subscriber = Object.new
      expect(subject.subscribe(subscriber)).to eq [subscriber]
      expect(subject.unsubscribe(subscriber)).to eq []
    end
  end

  describe '#emit' do
    it 'emits a message to all subscribers' do
      sub_a = Object.new
      allow(sub_a).to receive(:on_event_emitted) do |e|
        expect(e[:type]).to eq :test
      end

      sub_b = Object.new
      allow(sub_b).to receive(:on_event_emitted) do |e|
        expect(e[:type]).to eq :test
      end

      subject.subscribe(sub_a)
      subject.subscribe(sub_b)
      subject.emit(type: :test)
    end
  end
end
