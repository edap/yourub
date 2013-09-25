require 'logger'
# http://stackoverflow.com/questions/917566/ruby-share-logger-instance-among-module-classes
# https://github.com/mongoid/mongoid/blob/master/lib/mongoid/loggable.rb

module Logging
  def logger
    Logging.logger
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
