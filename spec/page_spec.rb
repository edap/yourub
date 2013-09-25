require 'yourub'

describe Yourub::Page do

  context "with valids arguments" do
    it "return an url" do
      page = Yourub::Page.new("US", "Sports", "most_recent")
      expect(page.url.to_s).to eq("https://gdata.youtube.com/feeds/api/standardfeeds/US/most_recent_Sports?v=2&alt=json&prettyprint=true(title,media:group(media:player(@url)))")
    end

    it "can connect to the url" do
      page = Yourub::Page.new("US", "Sports", "most_recent")
      expect(page.is_alive?).to be_true
    end
  end

  context "with invalid arguments" do
    it "raise an ArgumentError" do
      expect{ Yourub::Page.new("URSS", "Matrioska", "biggest") }.to raise_error(ArgumentError)
    end
  end
end