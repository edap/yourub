module Yourub
  module REST
    class Request
      attr_reader :data, :status

      # @param client [Yourub::Client]
      # @param resource_type [String]
      # @param method [String]
      # @param params [Hash]
      # @return [Youtube::Request]
      def initialize(client, resource_type, method, params)
        @client = client 
        @resource_type = resource_type
        @method = method
        @params = params
        perform
      end

      def perform
        r = @client.execute!(
          :api_method => @client.youtube_api.send(@resource_type.to_sym).send(@method.to_sym),
          :parameters => @params
        )    
        @data = r.data
        @status = r.status
      end

    end
  end
end
