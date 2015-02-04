require 'yourub'
require_relative '../../spec_helper'

describe Yourub::REST::Request do
  context 'during requests initialization' do
    include_context "stub client connection"
    let(:param) { { 'part' => 'snippet', 'regionCode' => 'de' } }

    describe 'the request object calls the execute! method on the client' do
      it 'execute the video list request on the client' do
        expect(client).to receive(:execute!).with(
          api_method: 'video_categories.list', parameters: param
        )
        Yourub::REST::Request.new(client, 'video_categories', 'list', param)
      end

      it 'execute the search list request on the client' do
        expect(client).to receive(:execute!).with(
          api_method: 'search.list', parameters: param
        )
        Yourub::REST::Request.new(client, 'search', 'list', param)
      end

      it 'execute the video list request on the client' do
        expect(client).to receive(:execute!).with(
          api_method: 'videos.list', parameters: param
        )
        Yourub::REST::Request.new(client, 'videos', 'list', param)
      end
    end
  end
end
