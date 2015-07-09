#require 'yourub/rest/search'
require 'yourub/rest/request'
require 'yourub/rest/categories'
require 'yourub/rest/search'
require 'yourub/rest/videos'

module Yourub
  module REST
  # @note WIP, the modules will follow the same grouping used in https://developers.google.com/youtube/v3/docs/.
    module API
      # include Yourub::REST::Playlists
      # include Yourub::REST::Channels
      include Yourub::REST::Search
      include Yourub::REST::Categories
      include Yourub::REST::Videos
    end
  end
end
