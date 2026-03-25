shared_context "search list result load fixture" do |fixture_file|
  let(:search_list_result){ double }
  let(:loaded_fixture) { fixture(fixture_file) }
  let(:search_list_items) do
    data = loaded_fixture
    if data.is_a?(Hash) && data.key?("items")
      data["items"]
    elsif data.is_a?(Array)
      data
    else
      raise ArgumentError, "search list fixture must be a searchListResponse or an items array"
    end
  end

  before do
    allow(search_list_result).to receive_message_chain(
      :data, :items).and_return(search_list_items)
    search_list_items.each do |single_video|
      video_id = if single_video.is_a?(Hash) && single_video["id"].is_a?(Hash)
        single_video["id"]["videoId"]
      else
        "video_id_stub"
      end
      allow(single_video).to receive_message_chain(
        :id, :video_id).and_return(video_id)
    end

    allow(Yourub::REST::Search).to receive(:list).and_return(search_list_result)
  end
end
