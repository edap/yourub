require 'yourub/meta_search'
require 'google/apis/youtube_v3'

module Yourub
  class Client
    include Yourub::MetaSearch

    attr_reader :videos

    # The Yourub::Client is a subclass of the Google::APIClient.
    #
    # @see http://www.rubydoc.info/github/google/google-api-ruby-client/Google/APIClient
    # In order to initialize the client, you have either to provide
    # a configuration file 'config/yourub.yml' in your main application folder
    # or to pass an hash in the initialization.
    # @example
    #    #passing an hash
    #    options = { developer_key: "a_secret_key",
    #                application_name: "my_app",
    #                application_version: 2.0,
    #                log_level: "INFO"}
    #    client = Yourub::Client.new(options)
    #
    # If you don't provide all the values, default values will be used.The only
    # mandatory value is the developer_key
    #
    # @example
    #   #assuming that you have a file in config/yourub.yml (see the example in
    #   #the source repository)
    #   client = Yourub::Client.new()

    def initialize(options = {})
      unless options.empty?
        Yourub::Config.override_config_file(options)
      end

      @service = Google::Apis::YoutubeV3::YouTubeService.new
      @service.key = config.developer_key
      @service.client_options.application_name = config.application_name
      @service.client_options.application_version = config.application_version
    end

    def countries
      Yourub::Validator.available_countries
    end

    # Compatibility shim used by Yourub::REST::Request
    def execute!(api_method:, parameters:)
      case api_method
      when :search_list
        part = parameters.delete(:part) || parameters.delete('part') || 'snippet'
        opts = normalize_search_params(parameters)
        data = @service.list_searches(part, **opts)
        OpenStruct.new(data: data, status: 200)
      when :videos_list
        part = parameters.delete(:part) || parameters.delete('part') || 'snippet'
        opts = normalize_videos_params(parameters)
        data = @service.list_videos(part, **opts)
        OpenStruct.new(data: data, status: 200)
      when :video_categories_list
        part = parameters.delete(:part) || parameters.delete('part') || 'snippet'
        opts = normalize_categories_params(parameters)
        data = @service.list_video_categories(part, **opts)
        OpenStruct.new(data: data, status: 200)
      else
        raise ArgumentError, "Unsupported api_method #{api_method.inspect}"
      end
    end

    def config
      Yourub::Config
    end

    private

    def normalize_search_params(params)
      transform_common_params(params).merge(
        {
          q: params[:q] || params['q'],
          type: params[:type] || params['type'],
          order: params[:order] || params['order'],
          safe_search: params[:safeSearch] || params['safeSearch']
        }.compact
      )
    end

    def normalize_videos_params(params)
      transform_common_params(params).merge(
        {
          id: params[:id] || params['id'],
          fields: params[:fields] || params['fields']
        }.compact
      )
    end

    def normalize_categories_params(params)
      transform_common_params(params)
    end

    def transform_common_params(params)
      {
        max_results: params[:maxResults] || params['maxResults'],
        region_code: params[:regionCode] || params['regionCode'],
        video_category_id: params[:videoCategoryId] || params['videoCategoryId']
      }.compact
    end
  end
end
