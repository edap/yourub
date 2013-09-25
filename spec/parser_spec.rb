require 'yourub'

describe Yourub::Parser do
  let(:page){Yourub::Page.new("US", "Howto", "most_recent")}

  it "give me an array of video" do
    options = {'views' => ">= 10"}
    parsed = Yourub::Parser.new(page.url, options)
    expect(parsed.videos).to be_a_kind_of(Array)
  end

  it "raise an error if an operator for the view count filter does not exists" do
    options = {'views' => '????? 10'}
    expect{ Yourub::Parser.new(page.url, options) }.to raise_error(ArgumentError)
  end

    it "raise an error if a filter does not exists" do
    options = {'roberto' => 'baggio'}
    expect{ Yourub::Parser.new(page.url, options) }.to raise_error(ArgumentError)
  end
end