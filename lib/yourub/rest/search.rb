require 'yourub/rest/request'

module Yourub
  module REST
    module Search
         
      def search(criteria)
        begin
          @api_options= {
            :part            => 'snippet',
            :type            => 'video',
            :order           => 'relevance',
            :safeSearch      => 'none',
           }

          @categories, @videos = [], []
          @count_filter = {}
          @criteria = Yourub::Validator.confirm(criteria)
          search_by_criteria
        rescue ArgumentError => e
          Yourub.logger.error "#{e}"
        end
      end

      def search_by_criteria
        if @criteria.has_key? :id
          search_by_id
        else
          merge_criteria_with_api_options
          retrieve_categories
          retrieve_videos
        end
      end

      def search_by_id
        params = {
          :id => @criteria[:id],
          :part => 'snippet,statistics',
        }
        video_response = videos_list_request(params)
        entry = Yourub::Reader.parse_videos(video_response)
        add_video_to_search_result(entry.first) unless entry.nil?
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
          get_categories_for_country(@criteria[:country])
          @categories = Yourub::Validator.valid_category(@categories, @criteria[:category])
        end
      end

      def get_categories_for_country(country)
        param = {"part" => "snippet","regionCode" => country }
        categories_list = video_categories_list_request(param)
        categories_list.data.items.each do |cat_result|
          category_name = parse_name(cat_result["snippet"]["title"])
          @categories.push(cat_result["id"] => category_name)
        end
      end

      def retrieve_videos
        consume_criteria do |criteria|
          begin
            req = search_list_request(criteria)
            get_details_and_store req
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

      def get_details_and_store(video_list)
        video_list.data.items.each do |video_item|
          params = video_params(video_item.id.videoId)
          v = videos_list_request(params) 
          v = Yourub::Reader.parse_videos(v)
          add_video_to_search_result(v.first) if v
        end
      end

      def search_list_request(params)
        send_request("search", "list", params)
      end

      def videos_list_request(params)
        send_request("videos", "list", params)
      end

      def video_categories_list_request(params)
        send_request("video_categories", "list", params)
      end

      def send_request(resource_type, method, params)
        #byebug
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

      def parse_name(name)
        return name.gsub("/", "-").downcase.gsub(/\s+/, "")
      end

      def get_views(id)
        params = {:id => id, :part => 'statistics'}
        request = videos_list_request(params)
        v = Yourub::Reader.parse_videos(request)
        v ? Yourub::CountFilter.get_views_count(v.first) : nil
      end

    end
  end
end
