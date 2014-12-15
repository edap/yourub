require 'yourub'

describe Yourub::REST::Search do

  context "Initialize the Request class if the given parameter are valid" do
    let(:subject) { Yourub::Client.new }

    # it "return an error if the given country does not exist" do
    #   subject.search(country: "MOON")
    #   expect(lambda{subject}).not_to raise_error()
    # end


    it "retrieves videos that have more than 100 views", focus:true do
      # allow_any_instance_of(Yourub::REST::Request).to receive(:new) do |req|
      #   req.method
      # end
      filter = {views: ">= 100"}
      subject.search(country: "US", category: "Sports", count_filter: filter)
      expect(subject.videos).to_not be_empty
    end

    it "retrieves videos for all the categories" do
      subject.search(country: "US", category: "all")
      expect(subject.videos).to_not be_empty
    end

    it "accept an 'order' parameter within the others" do
      subject.search(country: "US", category: "Sports", order: 'date')
      expect(subject.videos).to_not be_empty
    end

    it "retrieves 5 videos for each given category" do
      subject.search(country: "US, DE", category: "Sports", max_results: 5)
      expect(subject.videos.count).to eq(10)
    end

    it "retrieves 5 videos for each given category, also if they are passed as array" do
      subject.search(country: ["US", "DE"], category: "Sports", max_results: 5)
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

    it "retrieves the view count for given id" do
      expect(subject.get_views("mN0Dbj-xHY0")).to be_a_kind_of(Integer)
    end

    it "return nil for a not existing video" do
      subject.search(id: "fffffffffffffffffffff")
      expect(subject.videos).to be_empty
    end
  end

end

