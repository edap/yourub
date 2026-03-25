require 'yourub/rest/api'

module Yourub
  module MetaSearch
    include Yourub::REST::API

    # Search through the youtube API, executing multiple queries where necessary
    # @param criteria [Hash]
    # @example
    #   client = Yourub::Client.new
    #   client.search(country: "DE", category: "sports", order: 'date')
    def search(criteria)
      begin
        Yourub::CountFilter.filter = nil

        @api_options= {
          :part            => 'snippet',
          :type            => 'video',
          :order           => 'relevance',
          :safeSearch      => 'none',
          :q               => nil
        }

        @categories = []
        @count_filter = {}

        @api_options[:q] = criteria[:query] if criteria[:query]

        @criteria = Yourub::Validator.confirm(criteria)
        search_by_criteria do |result|
          yield result
        end
      rescue ArgumentError => e
        Yourub.logger.error "#{e}"
        raise
      end
    end

    # return an hash containing the metadata for the given video
    # @param video_id[Integer]
    # @example
    #   client = Yourub::Client.new
    #   client.get("G2b0OIkTraI")
    def get(video_id)
      params = {:id => video_id, :part => 'snippet,statistics'}
      request = Yourub::REST::Videos.list(self,params)
      Yourub::Result.format(request).first
    end

private

    def search_by_criteria
      merge_criteria_with_api_options
      retrieve_categories
      retrieve_videos do |res|
        yield res
      end
    end


    def merge_criteria_with_api_options
      @api_options[:q] = @criteria[:query] if @criteria[:query]
      @api_options[:maxResults] = @criteria[:max_results] if @criteria[:max_results]
      @api_options[:order] = @criteria[:order] if @criteria[:order]
    end

    def consume_criteria
      if @criteria[:country]
        @criteria[:country].each do |country|
          to_consume = @api_options.dup
          to_consume[:regionCode] = country
          consume_categories(to_consume) do |cat|
            yield cat
          end
        end
      else
        consume_categories(@api_options.dup) do |cat|
          yield cat
        end
      end
    end

    def consume_categories(to_consume)
      if @categories.size > 0
        @categories.each do |cat|
          current_params = to_consume.dup
          current_params[:videoCategoryId] = cat.keys[0].to_i
          yield current_params
        end
      else
        yield to_consume
      end
    end

    def retrieve_categories
      return unless @criteria.key?(:category)

      term = @criteria[:category].to_s.strip
      if term.empty?
        @categories = []
        return
      end

      if term.casecmp("all").zero?
        @categories = []
        return
      end

      region_code = region_code_for_category_catalog
      list = list_video_categories(region_code: region_code)
      items = video_category_list_items(list)
      match = find_category_item_by_partial_name(items, term)
      if match.nil?
        raise ArgumentError, category_not_found_message(term, items)
      end

      cid = video_category_item_id(match)
      @categories = [{ cid.to_s => term }]
    end

    def retrieve_videos
      consume_criteria do |criteria|
        begin
          req = Yourub::REST::Search.list(self, criteria)
          get_details_for_each_video(req) do |v|
            yield v
          end
        rescue StandardError => e
          Yourub.logger.error "Error #{e} retrieving videos for the criteria: #{criteria.to_s}"
        end
      end
    end


    def get_details_for_each_video(video_list)
      video_list.data.items.each do |video_item|
        v = Yourub::REST::Videos.single_video(self, video_item.id.video_id)
        v = Yourub::Result.format(v)
        if v && Yourub::CountFilter.accept?(v.first)
          yield v.first
        end
      end
    end

    def add_video_to_search_result(entry)
      if Yourub::CountFilter.accept?(entry)
        @videos.push(entry)
      end
    end

    def region_code_for_category_catalog
      return nil unless @criteria[:country].is_a?(Array) && @criteria[:country].any?

      @criteria[:country].first
    end

    def video_category_list_items(list)
      raw =
        if list.respond_to?(:items)
          list.items
        elsif list.is_a?(Hash)
          list["items"]
        end
      Array(raw)
    end

    def find_category_item_by_partial_name(items, search_term)
      needle = search_term.to_s.strip.downcase
      return nil if needle.empty?

      items.find do |item|
        title = video_category_item_title(item).to_s.downcase
        title.include?(needle)
      end
    end

    def video_category_item_title(item)
      if item.respond_to?(:snippet) && item.snippet.respond_to?(:title)
        item.snippet.title
      elsif item.is_a?(Hash)
        item.dig("snippet", "title")
      else
        ""
      end
    end

    def video_category_item_id(item)
      if item.respond_to?(:id)
        id = item.id
        id.is_a?(Hash) ? id["videoId"] || id[:videoId] : id
      elsif item.is_a?(Hash)
        item["id"]
      end
    end

    def category_not_found_message(term, items)
      lines = items.map do |it|
        "#{video_category_item_id(it)}: #{video_category_item_title(it)}"
      end
      <<~MSG.chomp
        category not found, this is the list of the available categories:
        #{lines.join("\n")}
      MSG
    end

  end
end
