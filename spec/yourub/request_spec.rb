require 'yourub'
require 'byebug'
#require 'signet/oauth_1/client'
#require_relative '../connection_helper'
require_relative '../spec_helper'

describe Yourub::REST::Request do
  #include ConnectionHelpers

  context "on initialize" do
    let(:subject) { Yourub::Client.new }
    let(:client) { Yourub::Client.new() }
    let(:discovered_api) { double("youtube_api")}

    describe 'when executing requests' do

      before do
        discovered_api.stub_chain(:videos, :list).and_return("videos.list")
        discovered_api.stub_chain(:search, :list).and_return("search.list")
        discovered_api.stub_chain(:video_categories, :list).and_return("video_categories.list")
        allow(subject).to receive(:youtube_api).and_return(discovered_api)
      end


      it "execute video list request" do
        param = {"part" => "snippet","regionCode" => "de" }
        fake_struct = OpenStruct.new(data: "bla", status: 200)
        allow(subject).to receive(:execute!).and_return(fake_struct)
        expect(subject).to receive(:execute!).with({api_method: "video_categories.list", parameters: param})
        Yourub::REST::Request.new(subject,"video_categories", "list", param)
      end
     

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

      it 'call the client with the right params' do
        byebug
        allow(subject).to receive(:execute!).and_return("The RSpec Book")
        allow(subject).to receive(:youtube_api).and_return(discovered_api)
        param = {"part" => "snippet","regionCode" => "de" }
        subject.search(country: "US", category: "Sports")
        expect(Yourub::REST::Request).to receive(:perform).with("videos_list", param)
      end

    end
  end

end
