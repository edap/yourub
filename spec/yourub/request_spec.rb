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
    let(:stubbed_response) {OpenStruct.new(data: "bla", status: 200)}
    let(:param) { {"part" => "snippet","regionCode" => "de" }}

    describe 'when executing requests' do

      before do
        discovered_api.stub_chain(:videos, :list).and_return("videos.list")
        discovered_api.stub_chain(:search, :list).and_return("search.list")
        discovered_api.stub_chain(:video_categories, :list).and_return("video_categories.list")
        allow(client).to receive(:youtube_api).and_return(discovered_api)
        allow(client).to receive(:execute!).and_return(stubbed_response)
      end


      it "execute the video list request on the client" do
        expect(client).to receive(:execute!).with({api_method: "video_categories.list", parameters: param})
        Yourub::REST::Request.new(client,"video_categories", "list", param)
      end

      it "execute the search list request on the client" do
        expect(client).to receive(:execute!).with({api_method: "search.list", parameters: param})
        Yourub::REST::Request.new(client,"search", "list", param)
      end

     
      it "execute the video list request on the client" do
        expect(client).to receive(:execute!).with({api_method: "videos.list", parameters: param})
        Yourub::REST::Request.new(client,"videos", "list", param)
      end

    end
  end

end
