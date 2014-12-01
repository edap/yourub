require 'yourub/rest/api'
require 'google/api_client'

module Yourub
  class Client < Google::APIClient
    include Yourub::REST::API

    attr_reader :videos
    attr_accessor :config

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

    def config
      Yourub::Config
    end

    def countries
      Yourub::Validator.available_countries
    end

    def youtube_api
      @youtube_api ||= self.discovered_api(config.youtube_api_service_name,
        config.youtube_api_version)
    end

  end
end
