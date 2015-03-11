require 'yourub/rest/request'

module Yourub
  module REST
    module PlaylistItems
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
          Yourub::REST::Request.new(client, "playlist_items", "list", params)
        end

        def single_playlist(client, playlist_id)
          params = single_playlist_params(playlist_id)
          list(client, params)
        end

        private

        def single_playlist_params(playlist_id)
          fields = URI::encode(
            'items(id,snippet(title,thumbnails),statistics(viewCount))'
          )
          { :id => video_id,
            :part => 'snippet,statistics,id',
            :fields => fields }
        end
      end
    end
  end
end
