require 'yourub'
require_relative '../../spec_helper.rb'

describe Yourub::REST::Videos do
  context "Initialize the Request class if the given parameter are valid" do
    let(:video_request) { double }
    let(:client) { Yourub::Client.new() }
    let(:videos) { fixture("videos_list.json") }

    before do
      allow(video_request).to receive_message_chain(:data, :items).and_return(videos)
      allow(Yourub::REST::Request).to receive(:new).and_return(video_request)
    end

    describe ".list" do
      it "create a request with the correct parameters" do
        expect(Yourub::REST::Request).to receive(:new)
          .with(client, "videos", "list", {"part"=>"snippet", "regionCode" => ['US']})
        subject.list(client, {"part"=>"snippet", "regionCode" => ['US']})
      end
    end
  end
end

