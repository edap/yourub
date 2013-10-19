require 'yaml'
require 'ostruct'
require 'forwardable'

module Yourub
  module Config

    class << self
      extend Forwardable
      attr_accessor :config

      def_delegators :@config, :developer_key,:youtube_api_service_name, :log_level,
                    :youtube_api_version, :application_name, :application_version

      def load!(file_path, environment)
        @config = OpenStruct.new YAML.load_file(file_path)[environment]
      end
    end

  end
end