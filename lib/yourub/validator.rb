module Yourub
  module Validator
    class << self
      #attr_reader :videos, :countrys, :categories

      DEFAULT_COUNTRY = "US" #if not given, a country it's necessary to retrieve a categories list
      COUNTRIES = [
        'AR','AU','AT','BE','BR','CA','CL','CO','CZ','EG','FR','DE','GB','HK',
        'HU','IN','IE','IL','IT','JP','JO','MY','MX','MA','NL','NZ','PE','PH',
        'PL','RU','SA','SG','ZA','KR','ES','SE','CH','TW','AE','US']

      VALID_PARAMS   = [:country, :category, :query, :id, :max_results, :count_filter]
      MINIMUM_PARAMS = [:country, :category, :query, :id]

      def confirm(criteria)
        @criteria = criteria
        valid_format?
        remove_empty_and_non_valid_params
        minimum_param_present?

        keep_only_the_id_if_present
        countries_to_array
        add_default_country_if_category_is_present
        validate_countries

        @criteria
      end

      def available_countries
        COUNTRIES
      end

      def remove_empty_and_non_valid_params
        @criteria.keep_if{|k,v| ( (VALID_PARAMS.include? k) && (v.size > 0)) }
      end

      def keep_only_the_id_if_present
        if @criteria.has_key? :id
          @criteria.keep_if{|k, _| k == :id}
        end
      end

      def countries_to_array
        if @criteria.has_key? :country
          @criteria[:country] = @criteria[:country].split(',').collect(&:strip)
        end
      end

      def add_default_country_if_category_is_present
        if (@criteria.has_key? :category) && (!@criteria.has_key? :country)
          @criteria[:country] = [ DEFAULT_COUNTRY ]
        end
      end

      def valid_category(categories, selected_category)
        categories = categories.select {|k| k.has_value?(selected_category.downcase)}
        if categories.first.nil?
          raise ArgumentError.new(
            "The category #{selected_category} does not exists in the following ones: #{categories.join(',')}")
        end
        return categories
      end

      def valid_format?
        raise ArgumentError.new(
          "give an hash as search criteria"
        ) unless( @criteria.is_a? Hash )
      end

      def minimum_param_present?  
        if @criteria.none?{|k,_| MINIMUM_PARAMS.include? k}
        raise ArgumentError.new(
          "minimum params to start a search is at least one of: #{MINIMUM_PARAMS.join(',')}"
        )
        end
      end

      def validate_countries
        if @criteria.has_key? :country
          raise ArgumentError.new(
            "the given country is not in the available ones: #{COUNTRIES.join(',')}"
          ) unless( (@criteria[:country] & COUNTRIES).size > 0 )
        end
      end

      def validate_max_results
        raise ArgumentError.new(
          'max 50 videos pro categories or country'
        ) unless(
          @criteria[:max_results].to_i < 50 || @criteria[:max_results].to_i == 0
        )
      end

    end
  end
end