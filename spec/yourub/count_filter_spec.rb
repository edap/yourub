require 'yourub'

describe Yourub::CountFilter do
  let(:video) {
    {"snippet" => {
      "title" => "GoPro: Hiero Day",
      "thumbnails" => {
        "default"=>{"url"=>"https://i1.ytimg.com/vi/mN0Dbj-xHY0/default.jpg"},
        "medium"=>{"url"=>"https://i1.ytimg.com/vi/mN0Dbj-xHY0/mqdefault.jpg"},
        "high"=>{"url"=>"https://i1.ytimg.com/vi/mN0Dbj-xHY0/hqdefault.jpg"},
        "standard"=>{"url"=>"https://i1.ytimg.com/vi/mN0Dbj-xHY0/sddefault.jpg"},
        "maxres"=>{"url"=>"https://i1.ytimg.com/vi/mN0Dbj-xHY0/maxresdefault.jpg"}
      }
    },
    "statistics"=>{"viewCount"=>"301"}
    }
  }

  let(:subject) { Yourub::CountFilter.accept?(video) }

  it "accept the video if satisfy the condition" do
    Yourub::CountFilter.filter = {views: ">= 100"}
    expect(subject).to eq true
  end

  it "accept the video if filter is nil" do
    Yourub::CountFilter.filter = nil
    expect(subject).to eq true
  end

  it "not accept the video if it does not satisfy the condition" do
    Yourub::CountFilter.filter = {views: "<= 100"}
    expect(subject).to eq false
  end
end
