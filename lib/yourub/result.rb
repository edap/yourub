module Yourub
  module Result
    class << self

      def format(request)
        data = nil
        if request.status == 200
          data = JSON.parse(request.data.items.to_json)
        end
        data
      end

        #resp example
        # [
        #   {"kind"=>"youtube#video",
        #    "etag"=>"\"F9iA7pnxqNgrkOutjQAa9F2k8HY/WkWGKMfWxthgmGABcMV_RsED5d8\"",
        #    "id"=>"mN0Dbj-xHY0",
        #    "snippet"=>{
        #      "publishedAt"=>"2013-10-17T22:08:28.000Z",
        #      "channelId"=>"UCqhnX4jA0A5paNd1v-zEysw",
        #      "title"=>"GoPro: Hiero Day",
        #      "description"=>"Shot 100% on the HD HERO3® camera from ‪http://GoPro.com.\n\nTo celebrate Hieroglyphics' influential force in underground music and art for over 20 years, Oakland, CA Mayor Jean Quan, proclaimed September 3rd as Hiero Day.\n\nMusic\nSouls of Mischief \"Cab Fare\"",
        #      "thumbnails"=>{
        #        "default"=>{"url"=>"https://i.ytimg.com/vi/mN0Dbj-xHY0/default.jpg", "width"=>120, "height"=>90},
        #        "medium"=>{"url"=>"https://i.ytimg.com/vi/mN0Dbj-xHY0/mqdefault.jpg", "width"=>320, "height"=>180},
        #        "high"=>{"url"=>"https://i.ytimg.com/vi/mN0Dbj-xHY0/hqdefault.jpg", "width"=>480, "height"=>360},
        #        "standard"=>{"url"=>"https://i.ytimg.com/vi/mN0Dbj-xHY0/sddefault.jpg", "width"=>640, "height"=>480},
        #        "maxres"=>{"url"=>"https://i.ytimg.com/vi/mN0Dbj-xHY0/maxresdefault.jpg", "width"=>1280, "height"=>720}
        #      },
        #      "channelTitle"=>"GoPro",
        #      "categoryId"=>"17",
        #      "liveBroadcastContent"=>"none"
        #    },
        #    "statistics"=>{
        #      "viewCount"=>"143272", "likeCount"=>"949", "dislikeCount"=>"219", "favoriteCount"=>"0", "commentCount"=>"91"
        #    }}
        # ]

      end
    end
  end
