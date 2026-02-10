require 'yourub'
require_relative '../spec_helper.rb'

describe Yourub::MetaSearch do
  context 'Initialize the Request class if the given parameter are valid' do

    let(:client) { Yourub::Client.new() }
    # let(:discovered_api) { double("youtube_api")}
    #let(:discovered_api) { double("youtube_api")}
    let(:response) {OpenStruct.new(data: {items: [{"statistics" => {"viewCount" => 2}}]}, status: 200)}
    let(:videos_list_response) { fixture("videos_list.json")}
    let(:search_list_response) { fixture("search_list.json")}
    let(:categories_formatted) { fixture("categories_list_formatted.json") }
    let(:single_video_response) { fixture("video_with_200_views.json") }
    let(:result){ double }

    before do
        # discovered_api.stub_chain(:data, :items).and_return(categories)
        # discovered_api.stub_chain(:search, :list).and_return("search.list")
        # discovered_api.stub_chain(:video_categories, :list).and_return("video_categories.list")
        # allow(client).to receive(:youtube_api).and_return(discovered_api)
        #allow(client).to receive(:execute!).and_return(response)
        #allow(Yourub::REST::Request).to receive(:new).and_return(response)
        allow(Yourub::Config).to receive(:developer_key).and_return('secret')
        allow(Yourub::Config).to receive(:application_name).and_return('yourub')
        allow(Yourub::Config).to receive(:application_version).and_return('1.0')
        allow(result).to receive(:status).and_return(200)
    end

    describe '#search' do
      context 'forward the parameters to the request' do
        include_context "search list result load fixture", "search_list.json"
        before do
          allow(Yourub::REST::Categories).to receive(
            :for_country).and_return(categories_formatted)
          allow(Yourub::REST::Videos).to receive(:list).and_return(response)
        end

        it 'creates a search list request with the expected parameters' do
          expect(Yourub::REST::Search).to receive(:list).with(
                client,
                {:part => "snippet",
                 :type => "video",
                 :order => "date",
                 :safeSearch => "none",
                 :category => "Sports",
                 :maxResults => 5,
                 :regionCode => "US",
                 :videoCategoryId => 17}
          )
          client.search(
            country: 'US', category: 'Sports', order: 'date', max_results: 5
          ) { |v| v }
        end
      end

      context 'integrates a view count filter' do
        include_context 'result load fixture', 'video_with_200_views.json'

        let(:search_result) { double }
        before do
          allow(search_result).to receive_message_chain(
            :data, :items).and_return(search_list_response)
          search_result.data.items.each do |single_video|
            allow(single_video).to receive_message_chain(
            :id, :video_id).and_return(1)
          end

          allow(Yourub::REST::Search).to receive(:list).and_return(search_result)
          allow(Yourub::REST::Videos).to receive(:single_video).and_return(result)
        end
        it 'retrieves videos that have more than 100 views' do
          filter = { views: '>= 100' }

          videos = []

          client.search(query: "nasa", count_filter: filter) do |v|
            videos.push(v)
          end

          expect(videos.count).to eq(4)
        end

       it 'retrieves no videos with more than 200 views' do
          filter = { views: '< 200' }

          videos = []

          client.search(query: "nasa", count_filter: filter ) do |v|
            videos.push(v)
          end

          expect(videos.count).to eq(0)
        end

      end

      # TODO
      # context 'iterates through the given nation' do
      #   it "retrieves 5 videos for each given category, also if they are passed as array" do
      #     videos = []
      #     subject.search(country: ["US", "DE"], category: "Sports", max_results: 5) do |v|
      #       videos.push v
      #     end
      #     expect(videos.count).to eq(10)
      #   end
      # end

      # context 'when the parameter category is == "all"' do
      #   it 'it iterates through all the categories' do
      #     videos = []
      #     client.search(country: 'US', category: 'all') do |v|
      #       videos.push v
      #     end
      #     expect(videos).to_not be_empty
      #   end
      # end
    end

    describe "methods used only for single video" do
      include_context "result load fixture", "video_with_200_views.json"

      describe '#get' do
        it 'send the request with the correct parameters' do
          expect(Yourub::REST::Request).to receive(:new)
            .with(client, 'videos', 'list', { :id => "mN0Dbj-xHY0", :part=>"snippet,statistics" })
          client.get('mN0Dbj-xHY0')
        end
      end

      describe '#get_views' do
        it 'send the request with the correct parameters' do
          expect(Yourub::REST::Request).to receive(:new)
            .with(client, 'videos', 'list', { :id => "mN0Dbj-xHY0", :part => "statistics" })
          client.get_views('mN0Dbj-xHY0')
        end

        it 'return the number of view for the given video' do
          expect(client.get_views('mN0Dbj-xHY0')).to eq(200)
        end
      end
    end
  end
end
