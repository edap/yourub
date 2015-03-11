require 'yourub/rest/request'

module Yourub
  module REST
    module Channels
      class << self
        # @param client[Yourub::Client]
        # @param params[hash]
        #
        #
        # @example
        #   client = Yourub::Client.new
        #   req = Yourub::REST::Channels.list(client, params)
        #

        def list(client, params)
          Yourub::REST::Request.new(client, "channels", "list", params)
        end

        def single_channel(client, channel_id)
          params = single_channel_params(channel_id)
          list(client, params)
        end

        private

        def single_channel_params(channel_id)
          fields = URI::encode(
            'items(id,snippet(title,thumbnails),statistics(viewCount))'
          )
          { :id => channel_id,
            :part => 'snippet,statistics,id',
            :fields => fields }
        end
      end
    end
  end
end
