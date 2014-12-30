require 'yourub'
require 'byebug'
#decommenta tutto questo fino alla fine di before
#require_relative '../../spec_helper.rb'


describe Yourub::REST::Search do
  context "Initialize the Request class if the given parameter are valid" do
    let(:client) { Yourub::Client.new() }
    #let(:discovered_api) { double("youtube_api")}
    #let(:discovered_api) { double("youtube_api")}
    let(:response) {OpenStruct.new(data: {items: [{"statistics" => {"viewCount" => 2}}]}, status: 200)}
    let(:response) {OpenStruct.new(data: {items: [{"statistics" => {"viewCount" => 2}}]}, status: 200)}
    let(:category_response) {OpenStruct.new(data: {items: [{"snippet" => {"title" => "Sport"}, "id" => 1}]}, status: 200)}
    let(:categories){
      [{"1"=>"film&animation"}, {"2"=>"autos&vehicles"}, {"10"=>"music"}, {"15"=>"pets&animals"}, {"17"=>"sports"}, {"18"=>"shortmovies"}, {"19"=>"travel&events"}, {"20"=>"gaming"}, {"21"=>"videoblogging"}, {"22"=>"people&blogs"}, {"23"=>"comedy"}, {"24"=>"entertainment"}, {"25"=>"news&politics"}, {"26"=>"howto&style"}, {"27"=>"education"}, {"28"=>"science&technology"}, {"29"=>"nonprofits&activism"}, {"30"=>"movies"}, {"31"=>"anime-animation"}, {"32"=>"action-adventure"}, {"33"=>"classics"}, {"34"=>"comedy"}, {"35"=>"documentary"}, {"36"=>"drama"}, {"37"=>"family"}, {"38"=>"foreign"}, {"39"=>"horror"}, {"40"=>"sci-fi-fantasy"}, {"41"=>"thriller"}, {"42"=>"shorts"}, {"43"=>"shows"}, {"44"=>"trailers"}]
    }
    before do
        # discovered_api.stub_chain(:data, :items).and_return(categories)
        # discovered_api.stub_chain(:search, :list).and_return("search.list")
        # discovered_api.stub_chain(:video_categories, :list).and_return("video_categories.list")
        # allow(client).to receive(:youtube_api).and_return(discovered_api)
        #allow(client).to receive(:execute!).and_return(response)
        #allow(Yourub::REST::Request).to receive(:new).and_return(response)
    end

    describe "#search" do
      it "create a request with the given parameters" do
        allow(Yourub::REST::Request).to receive(:new).and_return(category_response)
        expect(Yourub::REST::Request).to receive(:new)
          .with(client, "video_categories", "list", {"part"=>"snippet", "regionCode"=>["US"]})

        client.search(country: "US", category: "Sports") do |v|
          videos.push(v)
        end
      end

      it "retrieves videos that have more than 100 views" do
        filter = { views: ">= 100" }
        videos = []
        allow(Yourub::REST::Categories).to receive(:for_country).and_return(categories)
        expect(Yourub::REST::Request).to receive(:new)
          .with(client, "video_categories", "list", {"part"=>"snippet", "regionCode"=>["US"]})

        client.search(country: "US", category: "Sports", count_filter: filter) do |v|
          videos.push(v)
        end
      end

      it "retrieves videos for all the categories" do
        videos = []
        client.search(country: "US", category: "all") do |v|
          videos.push v
        end
        expect(videos).to_not be_empty
      end

      it "accept an 'order' parameter within the others" do
        videos = []
        client.search(country: "US", category: "Sports", order: 'date') do |v|
          videos.push v
        end
        expect(videos).to_not be_empty
      end

      it "retrieves 5 videos for each given category" do
        videos = []
        subject.search(country: "US, DE", category: "Sports", max_results: 5) do |v|
          videos.push v
        end
        expect(videos.count).to eq(10)
      end

      it "retrieves 5 videos for each given category, also if they are passed as array" do
        videos = []
        subject.search(country: ["US", "DE"], category: "Sports", max_results: 5) do |v|
          videos.push v
        end
        expect(videos.count).to eq(10)
      end

      it "retrieves the given number of video for the given category" do
        videos = []
        subject.search(category: "Sports", max_results: 2) do |v|
          videos.push v
        end
        expect(videos.count).to eq(2)
      end  

      it "retrieves the given number of video for the given word" do
        videos = []
        subject.search(query: "casa", max_results: 3) do |v|
          videos.push v
        end
        expect(videos.count).to eq(3)
      end    

      it "retrieves the given number of video for the given country" do
        videos = []
        client.search(country: "US", max_results: 5) do |v|
          videos.push v
        end
        expect(videos.count).to eq(5)
      end
    end

    describe "#get" do
      let(:response) {OpenStruct.new(data: {items: [{id: 2}]}, status: 200)}

      it "send the request with the correct parameters" do
        allow(Yourub::REST::Request).to receive(:new).and_return(response)
        expect(Yourub::REST::Request).to receive(:new)
          .with(client, "videos", "list", {:id=>"mN0Dbj-xHY0", :part=>"snippet,statistics"})
        client.get("mN0Dbj-xHY0")
      end

    end

    describe "#get_views" do
      let(:response) {OpenStruct.new(data: {items: [{"statistics" => {"viewCount" => 2}}]}, status: 200)}
      before do
        allow(Yourub::REST::Request).to receive(:new).and_return(response)
      end

      it "send the request with the correct parameters" do
        expect(Yourub::REST::Request).to receive(:new)
          .with(client, "videos", "list", {:id=>"mN0Dbj-xHY0", :part=>"statistics"})
        client.get_views("mN0Dbj-xHY0")
      end
      
      it "return the number of view for the given video" do
        expect(client.get_views("mN0Dbj-xHY0")).to eq(2)
      end

    end

  end
end

