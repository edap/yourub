module Yourub
  module REST
    class Request
      attr_reader :data, :status
      #
      # Once initializated, the Request object forward a request to
      # youtube api, once the request is completed, the variables @status and @data are populated
      #
      # @param client [Yourub::Client]
      # @param resource_type [String]
      # @param method [String]
      # @param params [Hash]
      #
      # @return [Youtube::Request]
      # @example
      #   Yourub::REST::Request.new(client,"video_categories", "list", param)
      #
      def initialize(client, resource_type, method, params)
        @client = client
        @resource_type = resource_type.to_sym
        @method = method.to_sym
        @params = params
        perform
      end

private
      #
      # call the 'execute!' method on the client
      #
      # == Returns :
      # The Request object with the variable @status and @data initialized
      # @status [Int]
      # @data [String]
      #
      def perform
        api_method =
          case [@resource_type, @method]
          when [:search, :list]
            :search_list
          when [:videos, :list]
            :videos_list
          when [:video_categories, :list]
            :video_categories_list
          else
            raise ArgumentError, "Unsupported resource_type/method: #{@resource_type}/#{@method}"
          end

        r = @client.execute!(api_method: api_method, parameters: @params.dup)
        @data = r.data
        @status = r.status
      end

    end
  end
end
