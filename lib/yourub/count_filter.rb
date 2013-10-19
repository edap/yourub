module Yourub
  module CountFilter
    class << self

      attr_accessor :filter

      VIEWS_COUNT_NUMBER = /\d*\z/
      ARITHMETIC_OPERATOR = /\A<(?!=)|>(?!=)|<=|>=|==|!=/

      def accept?(entry, filter)
        @filter = filter
        return true if @filter.nil?
        validate_filter
        apply_filter(entry)
      end

      def validate_filter
        unless @filter.is_a?(Hash)
          raise ArgumentError.new("The filter #{@filter} should be an Hash")
        end
        validate_count_filter
      end

      def validate_count_filter
        count_number_invalid = (@filter['views'] =~ VIEWS_COUNT_NUMBER).nil?
        operator_invalid = (@filter['views'] =~ ARITHMETIC_OPERATOR).nil?
        raise ArgumentError.new("arithmetic operator not detected") if operator_invalid
        raise ArgumentError.new("view count number not detected") if count_number_invalid
      end

      def apply_filter(video)
        operator = @filter['views'].match(ARITHMETIC_OPERATOR).to_s
        number_to_compare = @filter['views'].match(VIEWS_COUNT_NUMBER).to_s.to_i
        number_founded = get_views_count(video)
        return number_founded.send(operator, number_to_compare)
      end

      def get_views_count video
        return 0 if video['statistics'].nil?
        return video['statistics']["viewCount"].to_i
      end

    end
  end
end