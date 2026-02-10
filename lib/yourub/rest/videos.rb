require 'yourub/rest/request'

module Yourub
  module REST
    module Videos
      class << self
        # @param client[Yourub::Client]
        # @param params[hash]
        #
        #
        # @example
        #   client = Yourub::Client.new
        #   req = Yourub::REST::Videos.list(client, params)
        #

        def list(client, params)
          Yourub::REST::Request.new(client, "videos", "list", params)
        end

        def single_video(client, video_id)
          params = single_video_params(video_id)
          list(client, params)
        end

        private

        def single_video_params(video_id)
          fields = 'items(id,snippet(title,thumbnails),statistics(viewCount))'
          { :id => video_id,
            :part => 'snippet,statistics,id',
            :fields => fields }
        end
      end
    end
  end
end
