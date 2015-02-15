require 'yourub'
require_relative '../spec_helper.rb'


describe Yourub::MetaSearch do
  describe '#search' do
    let(:client) { Yourub::Client.new() }
    let(:result){ double }

    context 'integrates a view count filter' do
      context 'having a search result with 4 videos with 200 views' do
        include_context "stub client connection"
        include_context "search list result load fixture with single video", "search_list.json"
        context "searching videos with more or equal 200 views" do
          it 'find 4 videos' do
            filter = { views: '>= 200' }
            videos = []
            client.search(query: "nasa", count_filter: filter, max_results: 2) do |v|
              videos.push(v)
            end
            expect(videos.count).to eq(4)
          end
        end

        context "searching videos with more than 200 views" do
          it 'find 0 video' do
            filter = { views: '> 200' }
            videos = []
            client.search(query: "nasa", count_filter: filter, max_results: 2) do |v|
              videos.push(v)
            end
            expect(videos.count).to eq(0)
          end
        end

      end
    end
  end
end
