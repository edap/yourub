module Yourub
  class Client

    attr_reader :videos
    attr_accessor :config, :extended_info

    def initialize()
      @extended_info = false
      @categories, @videos = [], []
      @count_filter = {}
      @api_options= {
        :part            => 'snippet',
        :type            => 'video',
        :eventType       => 'completed',
        :order           => 'relevance',
        :safeSearch      => 'none',
      }
    end

    def config
      Yourub::Config
    end

    def countries
      Yourub::Validator.available_countries
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

    def search(criteria)
      begin
        @videos = []
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
      video_response = client.execute!(
        :api_method => youtube.videos.list,
        :parameters => params
      )
      entry = Yourub::Reader.parse_videos(video_response).first
      add_video_to_search_result(entry) unless entry.nil?
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
      categories_list = video_categories_list_request(country)
      categories_list.data.items.each do |cat_result|
        category_name = parse_name(cat_result["snippet"]["title"])
        @categories.push(cat_result["id"] => category_name)
      end
    end

    def retrieve_videos
      consume_criteria do |criteria|
        req = search_list_request(criteria)
        if @extended_info || Yourub::CountFilter.filter
          get_details_and_store req
        else
          videos = Yourub::Reader.parse_videos(req)
          videos.each{|v| add_video_to_search_result(v) }
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
        v = videos_list_request video_item.id.videoId
        v = Yourub::Reader.parse_videos(v).first
        add_video_to_search_result(v)
      end
    end

    def search_list_request(options)
      search_response = client.execute!(
        :api_method => youtube.search.list, 
        :parameters => options
      )
    end

    def videos_list_request(result_video_id)
      params = video_params(result_video_id)
      video_response = client.execute!(
        :api_method => youtube.videos.list,
        :parameters => params
      )
    end

    def video_categories_list_request(country)
      categories_list = client.execute!(
        :api_method => youtube.video_categories.list,
        :parameters => {"part" => "snippet","regionCode" => country }
      )
    end

    def video_params(result_video_id)
      parameters = {
        :id => result_video_id,
        :part => 'snippet,statistics,id',
      }
      unless @extended_info
        fields = 'items(id,snippet(title,thumbnails),statistics(viewCount))'
        parameters[:fields] = URI::encode(fields)
      end
      return parameters
    end

    def add_video_to_search_result(entry)
      video = @extended_info ? entry : Yourub::Reader.parse_entry(entry)
      if Yourub::CountFilter.accept?(entry)
        @videos.push(video)
      end
    end

    def parse_name(name)
      return name.gsub("/", "-").downcase.gsub(/\s+/, "")
    end

  end
end
