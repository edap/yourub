module Rails
  module Yourub
    class Railtie < Rails::Railtie

      config.yourub = ::Yourub::Config

      initializer "yourub.load-config" do
        config_file = Rails.root.join("config", "yourub.yml")
        if config_file.file?
          ::Yourub::Config.load!(config_file, Rails.env)
        end
      end

      initializer 'yourub.use-rails-logger' do
        ::Yourub.logger = Rails.logger
      end
    end
  end
end