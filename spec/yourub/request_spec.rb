require 'yourub'
require 'byebug'
require 'signet/oauth_1/client'
#require_relative '../connection_helper'
require_relative '../spec_helper'

describe Yourub::REST::Request do
  #include ConnectionHelpers

  context "on initialize" do
    let(:subject) { Yourub::Client.new }
    let(:client) { Yourub::Client.new() }

    describe 'when executing requests' do
      # before do
      #   @prediction = client.discovered_api('prediction', 'v1.2')
      #   @youtube_api = client.discovered_api('youtube', 'v3')
      #   client.authorization = :oauth_2
      #   @connection = stub_connection do |stub|
      #     stub.post('/prediction/v1.2/training?data=12345') do |env|
      #       expect(env[:request_headers]['Authorization']).to eq('Bearer 12345')
      #       [200, {}, '{}']
      #     end
      #   end
      # end


      it 'returns categories list' do
        param = {"part" => "snippet","regionCode" => "de" }
        fake_struct = OpenStruct.new(data: "bla", status: 200)
        # TODO, stubbing initialization params, create an helper for te struct
        # allow(Yourub::REST::Request).to receive(:new).with({client: client, resource:"video_categories", method: "list", p: param}).and_return fake_struct
        #allow(Yourub::REST::Request).to receive(:new).and_return fake_struct
        # questo sotto e' ok, puoi preparare delle fixtures da mettere in
        # fake struct.
        allow(Yourub::REST::Request).to receive(:new) { fake_struct }
        client.search(country: "US", category: "Sports")
        expect(client.videos.first.has_key? "statistics").to be true
      end


      it 'initialize request with the right value' do
        client.search(country: "US", category: "Sports")
        expect(Yourub::REST::Request).to receive(:perform).with("videos_list", param)
      end

    end
  end

end
