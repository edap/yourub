require 'yourub'

describe Yourub::Client do

  context "on initialize" do
    let(:subject) { Yourub::Client.new }

    it "return an error if the given country does not exist" do
      subject.search(country: "MOON")
      expect(lambda{subject}).not_to raise_error()
    end

    it "retrieves more infos with the option extended_info = true" do
      filter = {views: ">= 100"}
      subject.extended_info = true
      subject.search(country: "US", category: "Sports", count_filter: filter)
      expect(subject.videos.first.has_key? "statistics").to be_true
    end   

    it "retrieves videos that have more than 100 views" do
      filter = {views: ">= 100"}
      subject.search(country: "US", category: "Sports", count_filter: filter)
      expect(subject.videos).to be_a_kind_of(Array)
    end

    it "retrieves 5 videos for each given category" do
      subject.search(country: "US, DE", category: "Sports", max_results: 5)
      expect(subject.videos.count).to eq(10)
    end

    it "retrieves the given number of video for the given category" do
      subject.search(category: "Sports", max_results: 2)
      expect(subject.videos.count).to eq(2)
    end  

    it "retrieves the given number of video for the given word" do
      subject.search(query: "casa", max_results: 3)
      expect(subject.videos.count).to eq(3)
    end    

    it "retrieves the given number of video for the given country" do
      subject.search(country: "US", max_results: 5)
      expect(subject.videos.count).to eq(5)
    end

    it "retrieves a video for the given id" do
      subject.search(id: "mN0Dbj-xHY0")
      expect(subject.videos.first["id"]).to eql("mN0Dbj-xHY0")
    end

    it "return nil for a not existing video" do
      subject.search(id: "fffffffffffffffffffff")
      expect(subject.videos).to be_empty
    end
  end

end