module Yourub
  module Validator
    class << self

      COUNTRIES       = Yourub::CountryCodes::ISO_3166_1_ALPHA2
      ORDERS          = ['date', 'rating', 'relevance', 'title', 'videoCount', 'viewCount']
      VALID_PARAMS    = [:country, :category, :query, :max_results, :count_filter, :order ]

      def confirm(criteria)
        valid_format?(criteria)
        @criteria = symbolize_keys(criteria)

        remove_empty_and_non_valid_params
        validate_search_query

        validate_order
        validate_max_results
        countries_to_array
        validate_countries
        set_filter_count_options

        @criteria
      end

      def symbolize_keys(hash)
        hash.inject({}){|result, (key, value)|
          new_key = case key
                    when String then key.to_sym
                    else key
                    end
          new_value = case value
                      when Hash then symbolize_keys(value)
                      else value
                      end
          result[new_key] = new_value
          result
        }
      end


      def remove_empty_and_non_valid_params
        @criteria.reject! do |k, v|
          !VALID_PARAMS.include?(k) || v.nil? || (v.respond_to?(:empty?) && v.empty?)
        end
      end

      def countries_to_array
        if @criteria.has_key? :country
          if @criteria[:country].is_a?(String)
            @criteria[:country] = @criteria[:country].split(',').collect(&:strip)
          end
          @criteria[:country] = @criteria[:country].to_a
        end
      end

      def set_filter_count_options
        if @criteria.has_key? :count_filter
          Yourub::CountFilter.filter = @criteria.delete(:count_filter)
        end
      end

      def valid_category(categories, selected_category)
        categories = categories.select {|k| k.has_value?(selected_category.downcase.gsub(/\s+/, ""))}
        if categories.first.nil?
          raise ArgumentError.new("The category #{selected_category} does not exists...")
        end
        return categories
      end

      def valid_format?(criteria)
        raise ArgumentError.new(
          "give an hash as search criteria"
        ) unless( criteria.is_a? Hash )
      end

      def validate_search_query
        q = @criteria[:query]
        if !@criteria.key?(:query) || q.nil? || q.to_s.strip.empty?
          raise ArgumentError,
                "search requires a :query parameter."
        end
      end

      def validate_order
        if @criteria.has_key? :order
          raise ArgumentError.new(
            "the given order is not in the available ones: #{ORDERS.join(',')}"
          ) unless( ORDERS.include? @criteria[:order] )
        end
      end

      def validate_countries
        return unless @criteria.has_key?(:country)

        unknown = @criteria[:country] - COUNTRIES
        return if unknown.empty?

        raise ArgumentError,
              "invalid ISO 3166-1 alpha-2 country code(s): #{unknown.join(', ')}"
      end

      def validate_max_results
        raise ArgumentError.new(
          'max 50 videos pro categories or country'
        ) unless(
          @criteria[:max_results].to_i < 51 || @criteria[:max_results].to_i == 0
        )
      end

      def available_countries
        COUNTRIES
      end
    end
  end
end
