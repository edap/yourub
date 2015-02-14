shared_context "search list result load fixture with single video" do |fixture_file|
  let(:search_list_result) { double }
  let(:video_result) { double }
  let(:loaded_fixture) { fixture(fixture_file) }
  let(:video_with_200_views) { fixture('video_with_200_views.json') }

  before do
    # stub search list req
    allow(search_list_result).to receive_message_chain(
      :data, :items).and_return(loaded_fixture)
    search_list_result.data.items.each do |single_video|
      allow(single_video).to receive_message_chain(
      :id, :videoId).and_return(1)

    # stub single video request
    allow(video_result).to receive(:status).and_return(200)
    allow(video_result).to receive_message_chain(
      :data, :items).and_return(video_with_200_views)
    end

    allow(Yourub::REST::Search).to receive(:list).and_return(search_list_result)
    allow(Yourub::REST::Videos).to receive(:single_video).and_return(video_result)
  end
end
