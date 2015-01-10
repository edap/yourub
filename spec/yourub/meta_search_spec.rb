require 'yourub'
require 'byebug'
#decommenta tutto questo fino alla fine di before
require_relative '../spec_helper.rb'


describe Yourub::MetaSearch do
  context "Initialize the Request class if the given parameter are valid" do
    let(:client) { Yourub::Client.new() }
    #let(:discovered_api) { double("youtube_api")}
    #let(:discovered_api) { double("youtube_api")}
    let(:response) {OpenStruct.new(data: {items: [{"statistics" => {"viewCount" => 2}}]}, status: 200)}
    let(:response) {OpenStruct.new(data: {items: [{"statistics" => {"viewCount" => 2}}]}, status: 200)}
    let(:video_list_response) { fixture("video_list.json")}
    let(:search_list_response) { fixture("search_list.json")}
    let(:categories_formatted) { fixture("categories_list_formatted.json") }

    let(:fake){double}
    before do
        # discovered_api.stub_chain(:data, :items).and_return(categories)
        # discovered_api.stub_chain(:search, :list).and_return("search.list")
        # discovered_api.stub_chain(:video_categories, :list).and_return("video_categories.list")
        # allow(client).to receive(:youtube_api).and_return(discovered_api)
        #allow(client).to receive(:execute!).and_return(response)
        #allow(Yourub::REST::Request).to receive(:new).and_return(response)
    end

    describe "#search" do
      context "when a category is present in the search options" do
        before do
          allow(Yourub::REST::Categories).to receive(:for_countries).and_return(categories_formatted)
        end

        it "create a search request with the expected regionCode parameter" do
          fake.stub_chain(:data, :items).and_return(search_list_response)
          fake.stub(:status).and_return(200)
          allow(Yourub::REST::Search).to receive(:list).and_return(fake)
          expect(Yourub::REST::Search).to receive(:list)
            .with(client,{:part=>"snippet", :type=>"video", :order=>"relevance", :safeSearch=>"none", :category=>"Sports", :regionCode=>"US", :videoCategoryId=>17})
          client.search(country: "US", category: "Sports") do |v|
            videos.push(v)
          end
        end

        it "retrieves videos that have more than 100 views" do
          filter = { views: ">= 100" }
          videos = []
          allow(Yourub::REST::Categories).to receive(:for_countries).and_return(categories_formatted)

          expect(Yourub::REST::Request).to receive(:new).and_return(video_list_response)
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

