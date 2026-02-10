shared_context "stub client connection" do
  let(:client)           { Yourub::Client.new }
  let(:stubbed_response) { OpenStruct.new(data: 'bla', status: 200) }

  before do
    allow(client).to receive(:execute!).and_return(stubbed_response)
  end
end


