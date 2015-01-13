require 'yourub'
require 'byebug'
#require_relative '../spec_helper.rb'


describe Yourub::MetaSearch do
  context 'Initialize the Request class if the given parameter are valid' do
    let(:client) { Yourub::Client.new() }
    # let(:discovered_api) { double("youtube_api")}
    #let(:discovered_api) { double("youtube_api")}
    # let(:response) {OpenStruct.new(data: {items: [{"statistics" => {"viewCount" => 2}}]}, status: 200)}
    # let(:video_list_response) { fixture("video_list.json")}
    # let(:search_list_response) { fixture("search_list.json")}
    # let(:categories_formatted) { fixture("categories_list_formatted.json") }
    #
    #
    # {"id"=>"ljwjEyJJtJA", "snippet"=>{"title"=>"Watch: NASA launches Orion space capsule aboard Delta IV", "thumbnails"=>{"default"=>{"url"=>"https://i.ytimg.com/vi/ljwjEyJJtJA/default.jpg", "width"=>120, "height"=>90}, "medium"=>{"url"=>"https://i.ytimg.com/vi/ljwjEyJJtJA/mqdefault.jpg", "width"=>320, "height"=>180}, "high"=>{"url"=>"https://i.ytimg.com/vi/ljwjEyJJtJA/hqdefault.jpg", "width"=>480, "height"=>360}, "standard"=>{"url"=>"https://i.ytimg.com/vi/ljwjEyJJtJA/sddefault.jpg", "width"=>640, "height"=>480}}}, "statistics"=>{"viewCount"=>"72510"}}

    let(:result){double}

    describe '#search' do
        context 'integrates a view count filter' do
          it 'retrieves videos that have more than 100 views' do
            filter = { views: '>= 100' }
            videos = []

            client.search(query: "nasa", count_filter: filter, max_results: 2) do |v|
              videos.push(v)
            end

            expect(videos.count).to eq(2)
          end
        end
    end
  end
end
