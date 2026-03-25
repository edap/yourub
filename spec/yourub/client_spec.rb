require_relative '../spec_helper.rb'
require 'yourub'

describe Yourub::Client do
  it 'initialize a client through the config file' do
    allow(Yourub::Config).to receive(:developer_key).and_return('secret')
    allow(Yourub::Config).to receive(:application_name).and_return('youtube')
    allow(Yourub::Config).to receive(:application_version).and_return(10)

    client = Yourub::Client.new
    expect(client.config.developer_key).to eq('secret')
    expect(client.config.application_name).to eq('youtube')
    expect(client.config.application_version).to eq(10)
  end

  it 'initialize the client accepting an hash of option' do
    options = { developer_key: 'Super',
                application_name: 'yourub',
                application_version: 2.0,
                log_level: 3 }

    client = Yourub::Client.new(options)
    expect(client.config.developer_key).to eq('Super')
    expect(client.config.application_name).to eq('yourub')
    expect(client.config.application_version).to eq(2.0)
  end

  it 'use a default for the log level, if not provided' do
    options = { developer_key: 'Super' }
    client = Yourub::Client.new(options)
    expect(client.config.log_level).to eq('WARN')
  end

  it 'raise an argument error if there is no a developer_key in the option' do
    options = { application_name: 'my app' }
    expect { Yourub::Client.new(options) }.to raise_error(ArgumentError)
  end

  describe '#list_video_categories' do
    let(:options) do
      { developer_key: 'Super',
        application_name: 'yourub',
        application_version: 2.0,
        log_level: 3 }
    end
    let(:client) { Yourub::Client.new(options) }
    let(:service) { client.instance_variable_get(:@service) }
    let(:api_response) { Object.new }

    it 'delegates to YouTubeService with region_code' do
      expect(service).to receive(:list_video_categories).with(
        'snippet',
        region_code: 'DE'
      ).and_return(api_response)
      expect(client.list_video_categories(region_code: 'de')).to be(api_response)
    end

    it 'omits region_code when nil (YouTube default catalog, e.g. US)' do
      expect(service).to receive(:list_video_categories).with(
        'snippet'
      ).and_return(api_response)
      expect(client.list_video_categories).to be(api_response)
    end

    it 'omits region_code when blank' do
      expect(service).to receive(:list_video_categories).with(
        'snippet'
      ).and_return(api_response)
      expect(client.list_video_categories(region_code: '  ')).to be(api_response)
    end

    it 'passes hl when given' do
      expect(service).to receive(:list_video_categories).with(
        'snippet',
        region_code: 'US',
        hl: 'en_GB'
      ).and_return(api_response)
      expect(client.list_video_categories(region_code: 'US', hl: 'en_GB')).to be(api_response)
    end

    it 'caches per region_code and hl' do
      expect(service).to receive(:list_video_categories).once.with(
        'snippet',
        region_code: 'DE'
      ).and_return(api_response)
      2.times { expect(client.list_video_categories(region_code: 'DE')).to be(api_response) }
    end

    it 'flush_video_categories_cache! forces a new API call' do
      expect(service).to receive(:list_video_categories).twice.with(
        'snippet',
        region_code: 'FR'
      ).and_return(api_response)
      client.list_video_categories(region_code: 'FR')
      client.flush_video_categories_cache!
      client.list_video_categories(region_code: 'FR')
    end
  end
end
