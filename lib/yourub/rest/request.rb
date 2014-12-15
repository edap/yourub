module Yourub
  module REST
    class Request
      attr_reader :data, :status
      #
      # @param client [Yourub::Client]
      # @param resource_type [String]
      # @param method [String]
      # @param params [Hash]
      #
      # @return [Youtube::Request]
      #
      def initialize(client, resource_type, method, params)
        @client = client 
        @resource_type = resource_type.to_sym
        @method = method.to_sym
        @params = params
        perform
      end

      #
      # Pass the parameters needed to do a request to the Google::ApiClient
      #
      # == Returns :
      # The Request object with the variable @status and @data initialized
      # @status [Int]
      # @data [String]
      #
      def perform
        api_method =@client.youtube_api.send(@resource_type).send(@method) 
        r = @client.execute!(
          :api_method => api_method,
          :parameters => @params
        )    
        @data = r.data
        @status = r.status
      end

    end
  end
end
