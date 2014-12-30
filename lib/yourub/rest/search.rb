require 'yourub/rest/request'
require 'yourub/rest/categories'

module Yourub
  module REST
    module Search
      #include Categories
      #
      #include Yourub::REST::Categories

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
        params = {:id => video_id, :part => 'statistics'}
        request = videos_list_request(params)
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
        request = videos_list_request(params)
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
          #get_categories_for_country(@criteria[:country])
          #byebug
          #@categories = for_country(self,@criteria[:country])
          @categories = Yourub::REST::Categories.for_country(self,@criteria[:country])
          @categories = Yourub::Validator.valid_category(@categories, @criteria[:category])
        end
      end

      # def get_categories_for_country(country)
      #   param = {"part" => "snippet","regionCode" => country }
      #   categories_list = video_categories_list_request(param)

      #   byebug
      #   categories_list.data.items.each do |cat_result|
      #     category_name = parse_name(cat_result["snippet"]["title"])
      #     @categories.push(cat_result["id"] => category_name)
      #   end
      # end

      def retrieve_videos
        consume_criteria do |criteria|
          begin
            req = search_list_request(criteria)
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
          params = video_params(video_item.id.videoId)
          v = videos_list_request(params) 
          v = Yourub::Reader.parse_videos(v)
          #if v && Yourub::CountFilter.accept?(v.first)
          if v
            yield v.first
          end
        end
      end

      #ognuna di queste request deve essere migrata in un modulo a parte
      # questo modulo non fa parte della REST api, e dovrebbe essere chaiamato
      # MetaSearch

      def search_list_request(params)
        send_request("search", "list", params)
      end

      def videos_list_request(params)
        send_request("videos", "list", params)
      end

      # def video_categories_list_request(params)
      #   send_request("video_categories", "list", params)
      # end

      def send_request(resource_type, method, params)
        Yourub::REST::Request.new(self, resource_type, method, params)
      end

      def video_params(result_video_id)
        fields = URI::encode(
          'items(id,snippet(title,thumbnails),statistics(viewCount))'
        )
        { :id => result_video_id,
          :part => 'snippet,statistics,id',
          :fields => fields }
      end

      def add_video_to_search_result(entry)
        if Yourub::CountFilter.accept?(entry)
          @videos.push(entry)
        end
      end

      # def parse_name(name)
      #   return name.gsub("/", "-").downcase.gsub(/\s+/, "")
      # end

    end
  end
end
