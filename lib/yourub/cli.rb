require 'thor'

module Yourub
  class CLI < Thor
      desc 'hello NAME', 'Display greeting with given NAME'
      def hello(name)
        puts "Hello #{name}"
      end

      desc 'nations', 'display available nations in youtube standard feed'
      def nations
        Yourub::Search::NATION
      end

      desc 'feed_types', 'display available types in youtube standard feed'
      def feed_types
        Yourub.types
      end
  end
end