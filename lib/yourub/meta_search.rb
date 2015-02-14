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
        @api_options= {
          :part            => 'snippet',
          :type            => 'video',
          :order           => 'relevance',
          :safeSearch      => 'none',
         }
        @categories = []
        @count_filter = {}
        @criteria = Yourub::Validator.confirm(criteria)
        search_by_criteria do |result|
          yield result
        end
      rescue ArgumentError => e
        Yourub.logger.error "#{e}"
      end
    end

    # return the number of times a video was watched
    # @param video_id[Integer]
    # @example
    #   client = Yourub::Client.new
    #   client.get_views("G2b0OIkTraI")
    def get_views(video_id)
      params = { :id => video_id, :part => 'statistics' }
      request = Yourub::REST::Videos.list(self,params)
      v = Yourub::Result.format(request).first
      v ? Yourub::CountFilter.get_views_count(v) : nil
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
      mappings = {query: :q, max_results: :maxResults, country: :regionCode}
      @api_options.merge! @criteria
      @api_options.keys.each do |k|
        @api_options[ mappings[k] ] = @api_options.delete(k) if mappings[k]
      end
    end

    def retrieve_categories
      if @criteria.has_key? :category
        @categories = Yourub::REST::Categories.for_country(self,@criteria[:country])
        @categories = Yourub::Validator.valid_category(@categories, @criteria[:category])
      end
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

    def consume_criteria
      to_consume = @api_options
      if @criteria[:country]
        @criteria[:country].each do |country|
          to_consume[:regionCode] = country
          consume_categories(to_consume) do |cat|
            yield cat
          end
        end
      else
        yield to_consume
      end
    end

    def consume_categories(to_consume)
      if @categories.size > 0
        @categories.each do |cat|
          to_consume[:videoCategoryId] = cat.keys[0].to_i
          yield to_consume
        end
      else
        yield to_consume
      end
    end

    def get_details_for_each_video(video_list)
      video_list.data.items.each do |video_item|
        v = Yourub::REST::Videos.single_video(self, video_item.id.videoId)
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

  end
end
