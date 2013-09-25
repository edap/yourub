module Yourub
  class Page
    include Logging

    attr_accessor :url

    def initialize(nation = "US", category = "Sports", type = "most_recent")
      @nation          = nation
      @category        = category
      @type            = type
      @api_url         = "https://gdata.youtube.com/feeds/api/standardfeeds/"
      @json            = "?v=2&alt=json&prettyprint=true"
      @required_fields = "(title,media:group(media:player(@url)))"
      @url             = set_url
    end

    NATIONS = [
      'AR','AU','AT','BE','BR','CA','CL','CO','CZ','EG','FR','DE','GB','HK',
      'HU','IN','IE','IL','IT','JP','JO','MY','MX','MA','NL','NZ','PE','PH',
      'PL','RU','SA','SG','ZA','KR','ES','SE','CH','TW','AE','US',]

    CATEGORIES = [
      'Comedy', 'People', 'Entertainment', 'Music', 'Howto',
      'Sports', 'Autos', 'Education', 'Film', 'News', 'Animals',
      'Tech', 'Travel','Games', 'Shortmov']

    TYPES = [ 
      'top_rated', 'top_favorites', 'most_viewed', 'most_popular',
      'most_recent', 'most_discussed', 'most_linked', 'most_responded',
      'recently_featured', 'watch_on_mobile']      

    def valid?
      raise ArgumentError.new('params not available') unless(
          NATIONS.include?(@nation) && 
          CATEGORIES.include?(@category) && 
          TYPES.include?(@type)
        )
      true
    end

    def is_alive?
      begin
        Net::HTTP.start(@url.host, @url.port,
          :use_ssl => @url.scheme == 'https') do |https|
          addr = Net::HTTP::Get.new @url
          get_response(https, addr)
        end
      rescue StandardError => e
        return false
        logger.error "Error #{e} trying to connect to the given url #{@url}"       
      end
    end

    def get_response(https, addr)
      response = https.request addr
      return true if response.code == "200"
        
      logger.error "page #{@url} return code #{res.code}"
      return false
    end

    def set_url
      url = "#{@api_url}#{@nation}/#{@type}_#{@category}#{@json}#{@required_fields}"
      @url = URI.parse(url)
      return @url if (valid? && is_alive?)
    end

    # TODO

    # Va capito bene cosa e' un modulo e come si usa in una classe composta da diversi files
    # http://stackoverflow.com/questions/151505/difference-between-a-class-and-a-module

    # Gemme, due modi per organizzarle, il primo
    # nel file lib/gemma.rb vengono inclusi tutti i sotto files.
    # Ogninu di questi comincica con 
    # module NomeGemma e puo' includere classi o vattelapesca
    # un esempio e' tire
    # https://github.com/karmi/tire/blob/master/lib/tire.rb
    # e rake
    # https://github.com/jimweirich/rake/blob/master/lib/rake.rb

    # oppure nel file lib/gemma.rb
    # come in thor
    # https://github.com/erikhuda/thor/blob/master/lib/thor.rb
    # crei una classe col nome della gemma

    # esempio piu' chiaro e' faraday
    # https://github.com/lostisland/faraday/blob/master/lib/faraday.rb'
    
    # integrare un logger
    # tire ha un logger https://github.com/karmi/tire/blob/master/lib/tire/logger.rb
    # aggiungere diversi tipi di exception, far si che queste possano dialogre con la classe Logger
    # unire i due metodi di sopra
    # fare un test ciclando due url
    # aggiungere le Exception, facendo si che il ciclo passi alla seconda ulr se la prima non passa

    # pushare su github


  end
end