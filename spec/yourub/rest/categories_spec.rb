require 'yourub'
require_relative '../../spec_helper.rb'

describe Yourub::REST::Categories do
  context 'Initialize the Request class if the given parameter are valid' do
    let(:category_request)     { double }
    let(:client)               { Yourub::Client.new }
    let(:categories)           { fixture('categories_list.json') }
    let(:categories_formatted) { fixture('categories_list_formatted.json') }

    before do
      allow(category_request).to receive_message_chain(
        :data, :items
      ).and_return(categories)
      allow(Yourub::REST::Request).to receive(:new).and_return(category_request)
    end

    describe '.for_countries' do
      it 'create a request with the correct parameters' do
        expect(Yourub::REST::Request).to receive(:new)
          .with(client, 'video_categories', 'list',
                'part' => 'snippet', 'regionCode' => ['US'])
        subject.for_countries(client, ['US'])
      end

      it 'return an hash containing the id and the title for each category' do
        expect(subject.for_countries(client, ['US'])).to eq(
          categories_formatted
        )
      end
    end
  end
end
