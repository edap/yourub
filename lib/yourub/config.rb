require 'yaml'
require 'ostruct'
require 'forwardable'

module Yourub
  module Config

    class << self
      extend Forwardable
      attr_accessor :config

      def_delegators :@config, :developer_key, :log_level,
                    :application_name, :application_version

      MANDATORY_KEYS = [:developer_key, :application_name, :application_version, :log_level]

      # Only these keys are read from YAML or from +Client.new(opts)+. The API is always
      # YouTube Data API v3 via google-apis-youtube_v3 (+YouTubeService+).
      USER_CONFIG_KEYS = %i[developer_key application_name application_version log_level].freeze

      def load!(file_path, environment)
        raw = YAML.load_file(file_path)[environment]
        @config = OpenStruct.new(prune_config_hash(raw))
      end

      def override_config_file(hash)
        opt = valid_options(hash)
        @config = OpenStruct.new opt
      end

private

      def prune_config_hash(h)
        return {} unless h.is_a?(Hash)

        h.transform_keys { |k| k.to_sym }.slice(*USER_CONFIG_KEYS)
      end

      def valid_options(hash)
        normalized = hash.transform_keys { |k| k.to_sym }
        opt = default_options.merge(normalized.slice(*USER_CONFIG_KEYS))
        raise ArgumentError.new(
          "please provide an hash containing at least a valid developer_key"
        ) if opt[:developer_key].empty?
        return opt
      end

      def default_options
        {
          developer_key: "",
          application_name: "yourub",
          application_version: Yourub::VERSION,
          log_level: "WARN"
        }
      end

    end
  end
end
