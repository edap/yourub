require 'yourub'
require 'byebug'
require 'signet/oauth_1/client'
require_relative '../connection_helper'
#require_relative '../spec_helper'

describe Yourub::Client do
  include ConnectionHelpers

  context "on initialize" do
    let(:subject) { Yourub::Client.new }
    let(:client) { Yourub::Client.new() }



 describe 'when executing requests' do
    before do
      @prediction = client.discovered_api('prediction', 'v1.2')
      @youtube_api = client.discovered_api('youtube', 'v3')
      client.authorization = :oauth_2
      @connection = stub_connection do |stub|
        stub.post('/prediction/v1.2/training?data=12345') do |env|
          expect(env[:request_headers]['Authorization']).to eq('Bearer 12345')
          [200, {}, '{}']
        end
      end
    end

    after do
      #@connection.verify
    end
    
    it 'should use default authorization' do
      client.authorization.access_token = "12345"
      client.execute(  
        :api_method => @prediction.training.insert,
        :parameters => {'data' => '12345'},
        :connection => @connection
      )
    end

    it 'returns categories list' do
      param = {"part" => "snippet","regionCode" => "de" }
      fake_struct = OpenStruct.new(data: "bla", status: 200)
      # TODO, stubbing initialization params, create an helper for te struct
      # allow(Yourub::REST::Request).to receive(:new).with({client: client, resource:"video_categories", method: "list", p: param}).and_return fake_struct
      allow(Yourub::REST::Request).to receive(:new).and_return fake_struct
      client.search(country: "US", category: "Sports")
      expect(client.videos.first.has_key? "statistics").to be true
    end

    it 'should use request scoped authorization when provided' do
      client.authorization.access_token = "abcdef"
      new_auth = Signet::OAuth2::Client.new(:access_token => '12345')
      client.execute(  
        :api_method => @prediction.training.insert,
        :parameters => {'data' => '12345'},
        :authorization => new_auth,
        :connection => @connection
      )
    end
    
    it 'should accept options with batch/request style execute' do
      client.authorization.access_token = "abcdef"
      new_auth = Signet::OAuth2::Client.new(:access_token => '12345')
      request = client.generate_request(
        :api_method => @prediction.training.insert,
        :parameters => {'data' => '12345'}
      )
      client.execute(
        request,
        :authorization => new_auth,
        :connection => @connection
      )
    end
end





  describe 'configured for OAuth 1' do
    before do
      client.authorization = :oauth_1
      client.authorization.token_credential_key = 'abc'
      client.authorization.token_credential_secret = '123'
    end

    it 'should use the default OAuth1 client configuration' do
byebug
      expect(client.authorization.temporary_credential_uri.to_s).to eq(
        'https://www.google.com/accounts/OAuthGetRequestToken'
      )
      expect(client.authorization.authorization_uri.to_s).to include(
        'https://www.google.com/accounts/OAuthAuthorizeToken'
      )
      expect(client.authorization.token_credential_uri.to_s).to eq(
        'https://www.google.com/accounts/OAuthGetAccessToken'
      )
      expect(client.authorization.client_credential_key).to eq('anonymous')
      expect(client.authorization.client_credential_secret).to eq('anonymous')
    end

    #it_should_behave_like 'configurable user agent'
  end



    it "return an error if the given country does not exist" do
      subject.search(country: "MOON")
      expect(lambda{subject}).not_to raise_error()
    end

    it "give me a list of valid countries" do
      expect(subject.countries).to be_a_kind_of(Array)
    end

    it "retrieves more infos with the option" do
      byebug 
      filter = {views: ">= 100"}
      subject.search(country: "US", category: "Sports", count_filter: filter, extended_info: true)
      expect(subject.videos.first.has_key? "statistics").to be true
    end   

    it "retrieves videos that have more than 100 views" do
      filter = {views: ">= 100"}
      subject.search(country: "US", category: "Sports", count_filter: filter)
      expect(subject.videos).to_not be_empty
    end

    it "retrieves videos for all the categories" do
      subject.search(country: "US", category: "all")
      expect(subject.videos).to_not be_empty
    end

    it "accept an 'order' parameter within the others" do
      subject.search(country: "US", category: "Sports", order: 'date')
      expect(subject.videos).to_not be_empty
    end

    it "retrieves 5 videos for each given category" do
      subject.search(country: "US, DE", category: "Sports", max_results: 5)
      expect(subject.videos.count).to eq(10)
    end

    it "retrieves 5 videos for each given category, also if they are passed as array" do
      subject.search(country: ["US", "DE"], category: "Sports", max_results: 5)
      expect(subject.videos.count).to eq(10)
    end

    it "retrieves the given number of video for the given category" do
      subject.search(category: "Sports", max_results: 2)
      expect(subject.videos.count).to eq(2)
    end  

    it "retrieves the given number of video for the given word" do
      subject.search(query: "casa", max_results: 3)
      expect(subject.videos.count).to eq(3)
    end    

    it "retrieves the given number of video for the given country" do
      subject.search(country: "US", max_results: 5)
      expect(subject.videos.count).to eq(5)
    end

    it "retrieves a video for the given id" do
      subject.search(id: "mN0Dbj-xHY0")
      expect(subject.videos.first["id"]).to eql("mN0Dbj-xHY0")
    end

    it "retrieves the view count for given id" do
      expect(subject.get_views("mN0Dbj-xHY0")).to be_a_kind_of(Integer)
    end

    it "return nil for a not existing video" do
      subject.search(id: "fffffffffffffffffffff")
      expect(subject.videos).to be_empty
    end
  end

end
