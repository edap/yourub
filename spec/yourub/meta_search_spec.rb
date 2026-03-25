require 'yourub'
require_relative '../spec_helper.rb'

describe Yourub::MetaSearch do
  context 'Initialize the Request class if the given parameter are valid' do

    let(:client) { Yourub::Client.new() }
    let(:videos_list_items) do
      raw = fixture("videos_list.json")
      raw.is_a?(Hash) && raw["items"] ? raw["items"] : raw
    end
    let(:videos_list_request) do
      OpenStruct.new(status: 200, data: OpenStruct.new(items: videos_list_items))
    end
    let(:search_list_response) do
      raw = fixture("search_list.json")
      raw.is_a?(Hash) && raw["items"] ? raw["items"] : raw
    end
    let(:result){ double }

    before do
        allow(Yourub::Config).to receive(:developer_key).and_return('secret')
        allow(Yourub::Config).to receive(:application_name).and_return('yourub')
        allow(Yourub::Config).to receive(:application_version).and_return('1.0')
        allow(result).to receive(:status).and_return(200)
    end

    describe '#search' do
      context 'search.list for query nasa' do
        include_context "search list result load fixture", "search_list.json"

        before do
          allow(Yourub::REST::Videos).to receive(:list).and_return(videos_list_request)
        end

        it 'calls Search.list with snippet video search and q' do
          expect(Yourub::REST::Search).to receive(:list).with(
            client,
            {
              part: "snippet",
              type: "video",
              order: "relevance",
              safeSearch: "none",
              q: "nasa",
              maxResults: 5
            }
          )
          client.search(query: "nasa", max_results: 5) { |_v| }
        end
      end

      context 'category name resolves via list_video_categories' do
        let(:de_category_response) do
          items = fixture("categories_list.json").fetch("items").map do |h|
            OpenStruct.new(
              id: h["id"],
              snippet: OpenStruct.new(title: h.dig("snippet", "title"))
            )
          end
          OpenStruct.new(items: items)
        end

        include_context "search list result load fixture", "search_list.json"

        before do
          allow(client).to receive(:list_video_categories).and_return(de_category_response)
          allow(Yourub::REST::Videos).to receive(:list).and_return(videos_list_request)
        end

        it 'loads default catalog when country omitted and sets videoCategoryId' do
          expect(client).to receive(:list_video_categories).with(region_code: nil)
          expect(Yourub::REST::Search).to receive(:list).with(
            client,
            hash_including(
              q: "nasa",
              order: "relevance",
              videoCategoryId: 28
            )
          )
          client.search(query: "nasa", category: "science") { |_v| }
        end

        it 'uses first country for the category catalog when country is set' do
          expect(client).to receive(:list_video_categories).with(region_code: "DE")
          expect(Yourub::REST::Search).to receive(:list).with(
            client,
            hash_including(
              regionCode: "DE",
              q: "goals",
              videoCategoryId: 17
            )
          )
          client.search(query: "goals", country: "DE", category: "sports") { |_v| }
        end

        it 'raises ArgumentError listing categories when name does not match' do
          expect {
            client.search(query: "x", category: "zznotacategoryzz") { |_v| }
          }.to raise_error(ArgumentError, /category not found/)
        end

        it 'rejects category "all"' do
          expect {
            client.search(query: "nasa", category: "all") { |_v| }
          }.to raise_error(
            ArgumentError,
            'category "all" is not supported; omit :category to search without a video category filter.'
          )
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

          expect(videos.count).to eq(5)
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

    end

    describe "methods used only for single video" do
      include_context "result load fixture", 'video_with_200_views.json'

      describe '#get' do
        it 'send the request with the correct parameters' do
          expect(Yourub::REST::Request).to receive(:new)
            .with(client, 'videos', 'list', { :id => "yIlTwwJv1Ac", :part=>"snippet,statistics" })
          client.get('yIlTwwJv1Ac')
        end
      end
    end
  end
end
