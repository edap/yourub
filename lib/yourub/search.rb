module Yourub
  class Search

      attr_reader :videos, :nations, :categories
      attr_accessor :config

      def initialize(nation: "US", category: 'all', max_results: 2, filter: nil)
        local_variables.each do |k|
          v = eval(k.to_s)
          instance_variable_set("@#{k}", v) unless v.nil?
        end

        valid?

        @categories, @videos = [], []
        @options = default_search_video_options

        retrieve_categories
        retrieve_videos
      end

      def config
        Yourub::Config
      end

      NATIONS = [
        'AR','AU','AT','BE','BR','CA','CL','CO','CZ','EG','FR','DE','GB','HK',
        'HU','IN','IE','IL','IT','JP','JO','MY','MX','MA','NL','NZ','PE','PH',
        'PL','RU','SA','SG','ZA','KR','ES','SE','CH','TW','AE','US']

      def valid?
        validate_nation
        validate_max_results
      end

      def validate_nation
        raise ArgumentError.new('params not available') unless(
          NATIONS.include?(@nation)
        )
      end

      def validate_max_results
        raise ArgumentError.new('max 50 videos pro categories or nation') unless(
          @max_results.to_i < 50 || @max_results.to_i == 0
        )
      end

      def client
        @client ||= Google::APIClient.new(
          :key => config.developer_key,
          :application_name => config.application_name,
          :application_version => config.application_version,
          :authorization => nil,
        )
      end

      def youtube
        @youtube ||= client.discovered_api(config.youtube_api_service_name,
          config.youtube_api_version)
      end

      def categories_request
        categories_list = client.execute!(
          :api_method => youtube.video_categories.list,
          :parameters => {"part" => "snippet","regionCode" => @nation }
        )
      end

      def retrieve_categories
        retrieve_all_categories
        if @category != 'all'
          retrieve_only_one_category
        end
      end

      def retrieve_all_categories
        categories_request.data.items.each do |cat_result|
          @categories.push(cat_result["id"] => cat_result["snippet"]["title"])
        end
      end

      def retrieve_only_one_category
        @categories = @categories.select {|k| k.has_value?(@category)}
        if @categories.first.nil?
          raise ArgumentError.new('The category #{@category} does not exists')
        end
      end

      def default_search_video_options
        opt = {
          :maxResults      => @max_results,
          :regionCode      => @nation,
          :type            => 'video',
          :order           => 'date',
          :safeSearch      => 'none',
          :videoCategoryId => '10'
        }
      end

      def retrieve_videos
        #@nations.each do |nat|
          @categories.each do |cat|
            @options[:videoCategoryId] = cat.keys[0].to_i
            #@options[:regionCode] = nat
            @options[:part] = 'id'
            read_response videos_list_request
          end
        #end
      end

      def read_response(video_list)
        video_list.data.items.each do |video_item|
          video_info_request video_item.id.videoId
        end
      end

      def videos_list_request
        search_response = client.execute!(
          :api_method => youtube.search.list,
          :parameters => @options
        )
      end

      def video_info_request(result_video_id)
        params = video_params(result_video_id)
        video_response = client.execute!(
          :api_method => youtube.videos.list,
          :parameters => params
        )
        store_video(result_video_id, video_response)
      end

      def video_params(result_video_id)
        fields = 'items(snippet(title,thumbnails),statistics(viewCount))'
        parameters = {
          :id => result_video_id,
          :part => 'statistics,snippet',
          :fields => URI::encode(fields)
        }
      end

      def store_video(video_id, video_response)
        begin
          result = JSON.parse(video_response.data.to_json)
          entry = result['items'].first
          if Yourub::CountFilter.accept?(entry, @filter)
            @videos.push({
               'title' => entry['snippet']['title'],
               'url' => 'https://www.youtube.com/watch?v='<< video_id
            })
          end
        rescue StandardError => e
          Yourub.logger.error "Error #{e} reading the video stream"
        end
      end

  end
end