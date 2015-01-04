require 'yourub/rest/request'

module Yourub
  module REST
    module Search
      class << self
        # @param client[Yourub::Client]
        # @param params[hash]
        #
        #
        # @example
        #   client = Yourub::Client.new
        #   req = Yourub::REST::Search.list(client, params)
        #
        def list(client, params)
          Yourub::REST::Request.new(client,"search", "list", params)
        end
      end
    end
  end
end
