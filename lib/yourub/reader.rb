module Yourub
  module Reader
    class << self
      def parse_videos(videos)
        res = JSON.parse(videos.data.to_json)['items']
        return nil if res.blank?
        res
      end

      def parse_entry(entry)
        video_id = entry["id"]["videoId"] || entry['id']
        founded_video = {
           'id'    => video_id,
           'title' => entry['snippet']['title'],
           'thumb' => entry['snippet']['thumbnails']['default']['url'],
           'url'   => 'https://www.youtube.com/watch?v='<< video_id
        }
      end
    end
  end
end