require 'yourub/rest/request'

module Yourub
  module REST
    module Categories
      class << self
        # it returns an Array containing the categories for the given countries,
        # or the DEFAULT_COUNTRY if no countries was given.
        # @param client[Yourub::Client]
        # @param countries[Array]
        #
        #
        # @example
        #   client = Yourub::Client.new
        #   categories = Yourub::REST::Categories.for_country(client, ["US"])
        #
        def for_countries(client, countries)
          categories = []
          param = {"part" => "snippet","regionCode" => countries }
          categories_list = video_categories_list_request(client,param)
          categories_list.data.items.each do |cat_result|
            category_name = parse_name(cat_result["snippet"]["title"])
            categories.push(cat_result["id"] => category_name)
          end
          return categories
        end

  private
        def video_categories_list_request(client, params)
          Yourub::REST::Request.new(client,"video_categories", "list", params)
        end

        def parse_name(name)
          return name.gsub("/", "-").downcase.gsub(/\s+/, "")
        end
      end
    end
  end
end
