module Yourub
  class Parser
    include Logging

    attr_accessor :videos

    def initialize(url, filter_params = nil)
      @required_fields = "(title,media:group(media:player(@url)))"
      @videos = []
      @filter = filter_params
      @url = url
      read_url
    end

    COUNT_NUMBER = /\d*\z/
    ARITHMETIC_OPERATOR = /\A<(?!=)|>(?!=)|<=|>=|==|!=/

    def read_url
      parse_page unless url_not_present 
    end

    def parse_page
      validate_filter
      begin        
        page = open(@url, :read_timeout => 6).read
        json = JSON.parse(page)
        json['feed']['entry'].each {|v| process_video v}
      rescue StandardError => e
        logger.error "#{e}"
      end
    end

    def process_video video
        if filtered?(video)
          @videos.push parse_entry(video)
        end
    end


    def parse_entry entry
      views = get_views_count(entry)
      v = {
          title:       entry['title']['$t'],
          duration:    entry['media$group']['yt$duration'],
          date:        entry['published']['$t'],
          yt_id:       entry['media$group']['yt$videoid']['$t'],
          thumb_small: entry['media$group']['media$thumbnail'][0]['url'],
          thumb_big:   entry['media$group']['media$thumbnail'][3]['url'],
          views:       views
      }
      return v
    end

    def filtered? video
      return true if @filter.nil?
      apply_filter(video)
    end

    def apply_filter video
      #TODO, adding new filter
      if @filter.has_key?("views")
        views_count_filter(video)
      else
        return true
      end 
    end

    def views_count_filter video
      operator = @filter['views'].match(ARITHMETIC_OPERATOR).to_s
      number_to_compare = @filter['views'].match(COUNT_NUMBER).to_s.to_i
      number_founded = get_views_count(video)
      return number_founded.send(operator, number_to_compare)
    end
    
    def get_views_count video
      return 0 if video['yt$statistics'].nil?
      return video['yt$statistics']["viewCount"].to_i
    end

    def validate_filter
      return true if @filter.nil?
      unless @filter.is_a?(Hash)
        raise ArgumentError.new("The filter #{@filter} should be an Hash")
      end      
      validate_count_filter
    end

    def validate_count_filter
      count_number_invalid = (@filter['views'] =~ COUNT_NUMBER).nil?
      operator_invalid = (@filter['views'] =~ ARITHMETIC_OPERATOR).nil?
      raise ArgumentError.new("arithmetic operator not detected") if operator_invalid
      raise ArgumentError.new("view count number not detected") if count_number_invalid    
    end

    def url_not_present
      if @url.nil? || @url == false
        logger.error "no valid url given"
        return true 
      end
    end

  end
end