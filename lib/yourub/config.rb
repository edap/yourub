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

      MANDATORY_KEYS = [:developer_key, :application_name, :application_version, :log_level]

      # It loads the configuration file
      # this method is used in the railtie.rb and in the default.rb files
      # @example
      #   Yourub::Config.load!(File.join("config", "yourub.yml"), 'yourub_defaults')
      def load!(file_path, environment)
        @config = OpenStruct.new YAML.load_file(file_path)[environment]
      end

      def override_config_file(hash)
        opt = valid_options(hash)
        @config = OpenStruct.new opt
      end

private

      def valid_options(hash)
        opt = default_options.merge(hash)
        raise ArgumentError.new(
          "please provide an hash containing at least a valid developer_key"
        ) if opt[:developer_key].empty?
        return opt
      end

      def default_options
        {
          developer_key: "",
          youtube_api_service_name: "youtube",
          youtube_api_version: "v3",
          application_name: "yourub",
          application_version: Yourub::VERSION,
          log_level: "WARN"
        }
      end

    end
  end
end
