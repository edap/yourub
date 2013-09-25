require 'thor'

module Yourub
  class CLI < Thor
      desc 'hello NAME', 'Display greeting with given NAME'
      def hello(name)
        puts "Hello #{name}"
      end

      desc 'get_videos', 'ex: get_videos("US", "Sports", "most_recent")'
      def get_videos(nation, category, type, filter_params = nil)
        Yourub.get_videos(nation, category, type, filter_params = nil)
      end

      desc 'categories', 'display available categories in youtube standard feed'  
      def categories
        Yourub.categories
      end

      desc 'nations', 'display available nations in youtube standard feed'
      def nations
        Yourub.nations
      end

      desc 'feed_types', 'display available types in youtube standard feed'
      def feed_types
        Yourub.types
      end
  end
end