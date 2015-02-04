shared_context "stub client connection" do
  let(:client)           { Yourub::Client.new }
  let(:discovered_api)   { double('youtube_api') }
  let(:stubbed_response) { OpenStruct.new(data: 'bla', status: 200) }

  before do
    allow(discovered_api).to receive_message_chain(
      :videos, :list).and_return('videos.list')
    allow(discovered_api).to receive_message_chain(
      :search, :list).and_return('search.list')
    allow(discovered_api).to receive_message_chain(
      :video_categories, :list).and_return('video_categories.list')
    allow(client).to receive(:youtube_api).and_return(discovered_api)
    allow(client).to receive(:execute!).and_return(stubbed_response)
  end
end


