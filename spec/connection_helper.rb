require 'faraday'

Faraday::Adapter.load_middleware(:test)

module Faraday
  class Connection
    def verify
      if app.kind_of?(Faraday::Adapter::Test)
        app.stubs.verify_stubbed_calls
      else
        raise TypeError, "Expected test adapter"
      end
    end
  end
end

module ConnectionHelpers
  def stub_connection(&block)
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      block.call(stub)
    end

    Faraday.new do |builder|
      builder.options.params_encoder = Faraday::FlatParamsEncoder
      builder.adapter(:test, stubs)
    end
  end
end
