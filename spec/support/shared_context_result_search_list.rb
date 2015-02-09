shared_context "search list result load fixture" do |fixture_file|
  let(:search_list_result){ double }
  let(:loaded_fixture) { fixture(fixture_file) }

  before do
   # search list req
    allow(search_list_result).to receive_message_chain(
      :data, :items).and_return(loaded_fixture)
    search_list_result.data.items.each do |single_video|
      allow(single_video).to receive_message_chain(
      :id, :videoId).and_return(1)
    end

    allow(Yourub::REST::Search).to receive(:list).and_return(search_list_result)
  end
end
