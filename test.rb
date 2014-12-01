require "singleton"

class Casa
  attr_reader :beppe
include Singleton

  def intialize
    @beppe = "beppe"
  end

  def capo
    puts @beppe
  end
end

casa = Casa.instance
puts casa.capo



