shared_context "result load fixture" do |fixture_file|
  let(:result){ double }
  let(:loaded_fixture) { fixture(fixture_file) }

  before do
    allow(result).to receive(:status).and_return(200)
    allow(result).to receive_message_chain(
      :data, :items).and_return(loaded_fixture)
    allow(Yourub::REST::Request).to receive(:new).and_return(result)
  end
end
