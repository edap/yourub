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

  it "accept the video if satisfy the condition" do
    count_filter = {'views' => ">= 100"}
    res = Yourub::CountFilter.accept?(video, count_filter)
    expect(res).to be_true
  end

  it "accept the video if filter is nil" do
    count_filter = nil
    res = Yourub::CountFilter.accept?(video, count_filter)
    expect(res).to be_true
  end

  it "not accept the video if it does not satisfy the condition" do
    count_filter = {'views' => "< 10"}
    res = Yourub::CountFilter.accept?(video, count_filter)
    expect(res).to be_false
  end

end