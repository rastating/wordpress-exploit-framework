require_relative '../spec_helper'

describe Wpxf::WordPress::Posts do
  let(:subject) do
    Class.new(Wpxf::Module) do
      include Wpxf::WordPress::Posts
    end.new
  end

  describe '#get_post_id_from_body' do
    it 'extracts the post id from the specified body' do
      body = '<body class="single single-post postid-1 single-format-standard">'
      expect(subject.get_post_id_from_body(body)).to eq '1'
    end

    it 'returns nil if a post id cannot be found' do
      expect(subject.get_post_id_from_body('invalid')).to be_nil
    end
  end

  describe '#get_post_id_from_permalink' do
    it 'extracts the post id from the requested page' do
      body = '<body class="single single-post postid-1 single-format-standard">'
      res = Wpxf::Net::HttpResponse.new(nil)
      res.body = body
      res.code = 200
      allow(subject).to receive(:execute_get_request).and_return res
      expect(subject.get_post_id_from_permalink('127.0.0.1/post-1')).to eq '1'
    end

    it 'returns nil if the response code isn\'t 200' do
      res = Wpxf::Net::HttpResponse.new(nil)
      res.code = 404
      allow(subject).to receive(:execute_get_request).and_return res
      expect(subject.get_post_id_from_permalink('127.0.0.1/post-1')).to be_nil
    end

    it 'returns nil if a post id cannot be found' do
      res = Wpxf::Net::HttpResponse.new(nil)
      res.body = 'invalid'
      res.code = 200
      allow(subject).to receive(:execute_get_request).and_return res
      expect(subject.get_post_id_from_permalink('127.0.0.1/post-1')).to be_nil
    end
  end
end
