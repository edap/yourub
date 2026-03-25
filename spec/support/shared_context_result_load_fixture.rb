shared_context "result load fixture" do |fixture_file|
  let(:result){ double }
  let(:loaded_fixture) { fixture(fixture_file) }
  let(:loaded_items) do
    data = loaded_fixture
    if data.is_a?(Hash) && data.key?("items")
      data["items"]
    elsif data.is_a?(Array)
      data
    else
      raise ArgumentError,
            "#{fixture_file} must be a YouTube list response with an items array or a bare items array"
    end
  end

  before do
    allow(result).to receive(:status).and_return(200)
    allow(result).to receive_message_chain(
      :data, :items).and_return(loaded_items)
    allow(Yourub::REST::Request).to receive(:new).and_return(result)
  end
end
