require 'yourub'

describe Yourub::Search do

  context "on initialize" do
    it "retrieves all the available categories for the default country" do
      result = Yourub::Search.new()
      expect(result.categories).to be_a_kind_of(Array)
    end

    it "retrieves all the available categories for a given country" do
      result = Yourub::Search.new(nation: "US")
      expect(result.categories).to be_a_kind_of(Array)
    end

    it "return an error if the given country does not exists" do
      expect{ Yourub::Search.new(nation: "MOON") }.to raise_error(ArgumentError)
    end

    it "return an error if the given category does not exists" do
      expect{ Yourub::Search.new(nation: "US", category: "Puzzles") }.to raise_error
    end

    it "initialize the instance variabe @category with the given category" do
      result = Yourub::Search.new(nation: "US", category: "Sports")
      expect(result.categories.first.values).to include("Sports")
      expect(result.categories.first.key("Sports").to_i).to be_a_kind_of(Integer)
    end

    it "retrieves 2 videos pro category if no max_results is specified" do
      result = Yourub::Search.new(nation: "US", category: "Sports")
      expect(result.videos.count).to eq(2)
    end

    it "retrieves 5 videos pro category max_results = 5" do
      result = Yourub::Search.new(nation: "US", category: "Sports", max_results: 5)
      expect(result.videos.count).to eq(5)
    end

    it "retrieves videos that have more than 100 views" do
      filter = {'views' => ">= 100"}
      result = Yourub::Search.new(nation: "US", category: "Sports", max_results: 5, filter: filter)
      expect(result.videos).to be_a_kind_of(Array)
    end
  end

end