require 'yourub'

#That is an integration test where the client is not stubbed, this test can
#pass only with an internet connection and a valid developer key. Use this test
#at the end of your changes, and add new tests if you have added new
#functionalities. This file is not run in the default spec suite
describe Yourub::Client do

  context "on initialize" do
    let(:subject) { Yourub::Client.new }

    before do
    end

    it "return an error if the given country does not exist" do
      subject.search(country: "MOON")
      expect(lambda{subject}).not_to raise_error()
    end

    it "give me a list of valid countries" do
      expect(subject.countries).to be_a_kind_of(Array)
    end

    it "retrieves videos that have more than 100 views" do
      filter = {views: ">= 100"}
      videos = []
      subject.search(country: "US", category: "Sports", count_filter: filter) do |v|
        videos.push(v)
      end
      expect(videos).to_not be_empty
    end

    it "retrieves videos for all the categories" do
      videos = []
      subject.search(country: "US", category: "all") do |v|
        videos.push(v)
      end
      expect(videos).to_not be_empty
    end

    it "accept an 'order' parameter within the others" do
      videos = []
      subject.search(country: "US", category: "Sports", order: 'date') do |v|
        videos.push(v)
      end
      expect(videos).to_not be_empty
    end

    it "retrieves 5 videos for each given category" do
      videos = []
      subject.search(country: "US, DE", category: "Sports", max_results: 5) do |v|
        videos.push(v)
      end
      expect(videos.count).to eq(10)
    end

    it "retrieves 5 videos for each given category, also if they are passed as array" do
      videos = []
      subject.search(country: ["US", "DE"], category: "Sports", max_results: 5) do |v|
        videos.push(v)
      end
      expect(videos.count).to eq(10)
    end

    it "retrieves the given number of video for the given category" do
      videos = []
      subject.search(category: "Sports", max_results: 2) do |v|
        videos.push(v)
      end
      expect(videos.count).to eq(2)
    end

    it "retrieves the given number of video for the given word" do
      videos = []
      subject.search(query: "casa", max_results: 3) do |v|
        videos.push(v)
      end
      expect(videos.count).to eq(3)
    end

    it "retrieves the given number of video for the given country" do
      videos = []
      subject.search(country: "US", max_results: 5) do |v|
        videos.push(v)
      end
      expect(videos.count).to eq(5)
    end

    # it "retrieves a video for the given id" do
    #   subject.search(id: "mN0Dbj-xHY0")
    #   expect(videos.first["id"]).to eql("mN0Dbj-xHY0")
    # end

    # it "retrieves the view count for given id" do
    #   expect(subject.get_views("mN0Dbj-xHY0")).to be_a_kind_of(Integer)
    # end

    # it "return nil for a not existing video" do
    #   subject.search(id: "fffffffffffffffffffff")
    #   expect(subject.videos).to be_empty
    # end
  end

end

