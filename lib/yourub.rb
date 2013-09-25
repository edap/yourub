require 'yourub/version'
require 'json'
require 'logger'

require 'open-uri'
require 'net/https'
require 'yourub/logging'

require 'yourub/parser'
require 'yourub/page'


module Yourub

  #@logger ||= self.default_logger
  class << self
    include Logging

    # attr_accessor :logger

    # def logger
    #   Logging.logger
    # end

    def get_videos(nation, category, type, filter_params = nil)
      page = Yourub::Page.new(nation, category, type)
      parsed = Yourub::Parser.new(page.url, filter_params)
      @videos = parsed.videos
    end

    def categories
      Yourub::Page::CATEGORIES
    end

    def nations
      Yourub::Page::NATIONS
    end

    def feed_types
      Yourub::Page::TYPES
    end

  end

end

