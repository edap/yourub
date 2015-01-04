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
        #   categories = Yourub::REST::Videos.list(client, params)
        #
        def list(client, params)
          Yourub::REST::Request.new(client,"videos", "list", params)
        end

      end
    end
  end
end
