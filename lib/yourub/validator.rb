module Yourub
  module Validator
    class << self

      DEFAULT_COUNTRY = "US"
      COUNTRIES       = [ 'AR','AU','AT','BE','BR','CA','CL','CO','CZ','EG','FR','DE','GB','HK',
                          'HU','IN','IE','IL','IT','JP','JO','MY','MX','MA','NL','NZ','PE','PH',
                          'PL','RU','SA','SG','ZA','KR','ES','SE','CH','TW','AE','US']
      ORDERS          = ['date', 'rating', 'relevance', 'title', 'videoCount', 'viewCount']
      VALID_PARAMS    = [:country, :category, :query, :id, :max_results, :count_filter, :order ]
      MINIMUM_PARAMS  = [:country, :category, :query, :id]

      def confirm(criteria)
        valid_format?(criteria)
        @criteria = symbolize_keys(criteria)

        remove_empty_and_non_valid_params
        minimum_param_present?

        keep_only_the_id_if_present
        validate_order
        countries_to_array
        add_default_country_if_category_is_present
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
        @criteria.keep_if{|k,v| ( (VALID_PARAMS.include? k) && v.size > 0) }
      end

      def keep_only_the_id_if_present
        if @criteria.has_key? :id
          @criteria.keep_if{|k, _| k == :id}
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

      def add_default_country_if_category_is_present
        if (@criteria.has_key? :category) && (!@criteria.has_key? :country)
          @criteria[:country] = [ DEFAULT_COUNTRY ]
        end
      end

      def set_filter_count_options
        if @criteria.has_key? :count_filter
          Yourub::CountFilter.filter = @criteria.delete(:count_filter)
        end
      end

      def valid_category(categories, selected_category)
        return categories if selected_category == 'all'
        categories = categories.select {|k| k.has_value?(selected_category.downcase)}
        if categories.first.nil?
          raise ArgumentError.new(
            "The category #{selected_category} does not exists in the following ones: #{categories.join(',')}")
        end
        return categories
      end

      def valid_format?(criteria)
        raise ArgumentError.new(
          "give an hash as search criteria"
        ) unless( criteria.is_a? Hash )
      end

      def minimum_param_present?  
        if @criteria.none?{|k,_| MINIMUM_PARAMS.include? k}
        raise ArgumentError.new(
          "minimum params to start a search is at least one of: #{MINIMUM_PARAMS.join(',')}"
        )
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
        if @criteria.has_key? :country
          raise ArgumentError.new(
            "the given country is not in the available ones: #{COUNTRIES.join(',')}"
          ) unless( (@criteria[:country] - COUNTRIES).size == 0 )
        end
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
