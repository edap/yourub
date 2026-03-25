require 'yourub'
require_relative '../../spec_helper.rb'

describe Yourub::REST::Categories do
  context 'Initialize the Request class if the given parameter are valid' do
    let(:category_request)     { double }
    let(:client)               { Yourub::Client.new(client_options) }
    let(:client_options) do
      { developer_key: 'secret',
        application_name: 'yourub',
        application_version: '1.0',
        log_level: 'WARN' }
    end
    let(:category_items)       { fixture('categories_list.json').fetch('items') }
    let(:categories_objects) do
      category_items.map do |h|
        OpenStruct.new(
          id: h['id'],
          snippet: OpenStruct.new(title: h.dig('snippet', 'title'))
        )
      end
    end
    let(:categories_formatted) do
      category_items.map do |h|
        title = h.dig('snippet', 'title')
        slug = title.gsub("/", "-").downcase.gsub(/\s+/, "")
        { h['id'] => slug }
      end
    end

    before do
      allow(category_request).to receive_message_chain(
        :data, :items
      ).and_return(categories_objects)
      allow(Yourub::REST::Request).to receive(:new).and_return(category_request)
    end

    describe '.for_country' do
      it 'create a request with the correct parameters' do
        expect(Yourub::REST::Request).to receive(:new)
          .with(
            client,
            'video_categories',
            'list',
            { 'part' => 'snippet', 'regionCode' => 'US' }
          )
        subject.for_country(client, ['US'])
      end

      it 'return an hash containing the id and the title for each category' do
        expect(subject.for_country(client, ['US'])).to eq(
          categories_formatted
        )
      end
    end
  end
end
