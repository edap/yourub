require 'yourub/meta_search'
require 'google/api_client'

module Yourub
  class Client < Google::APIClient
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

      args = {
        :key => config.developer_key,
        :application_name => config.application_name,
        :application_version => config.application_version,
        :authorization => nil
      }
      super(args)
    end

    # @return countries [Array] contain a list of the available alpha-2 country codes ISO 3166-1
    def countries
      Yourub::Validator.available_countries
    end

    # it returns the youtube service object
    # @see http://www.rubydoc.info/github/google/google-api-ruby-client/Google/APIClient#discovered_api-instance_method
    def youtube_api
      @youtube_api ||= self.discovered_api(
        config.youtube_api_service_name, config.youtube_api_version
      )
    end

    def config
      Yourub::Config
    end
  end
end
