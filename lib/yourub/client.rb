require 'yourub/rest/api'
require 'google/api_client'

module Yourub
  class Client < Google::APIClient
    include Yourub::REST::API

    attr_reader :videos
    #attr_accessor :config

    # The Yourub::Client is a subclass of the Google::APIClient
    # @see http://www.rubydoc.info/github/google/google-api-ruby-client/Google/APIClient

    def initialize()
      # here you could accept an hash as argument, in order
      # to initialize te client in a CLI, and override later the value
      # if a config file is present
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
      @youtube_api ||= self.discovered_api(config.youtube_api_service_name,
        config.youtube_api_version)
    end

private
    def config
      Yourub::Config
    end

  end
end
