#require 'yourub/rest/search'
require 'yourub/rest/request'
require 'yourub/rest/categories'
require 'yourub/rest/search'
require 'yourub/rest/videos'
require 'yourub/rest/channels'
require 'yourub/rest/playlists'
require 'yourub/rest/playlist_items'


module Yourub
  module REST
  # @note WIP, the modules will follow the same grouping used in https://developers.google.com/youtube/v3/docs/.
    module API
      include Yourub::REST::Playlists
      include Yourub::REST::PlaylistItems
      include Yourub::REST::Channels
      include Yourub::REST::Search
      include Yourub::REST::Categories
      include Yourub::REST::Videos
    end
  end
end
