#require 'webmock/rspec'

#WebMock.disable_net_connect!(allow_localhost: true)
RSpec.configure do |c|
  c.filter_run_including :focus => true
end

def a_get(path)
  a_request(:get, Yourub::REST::Request::BASE_URL + path)
end

def stub_get(path)
  stub_request(:get, Yourub::REST::Request::BASE_URL + path)
end

def capture_warning
  begin
    old_stderr = $stderr
    $stderr = StringIO.new
    yield
    result = $stderr.string
  ensure
    $stderr = old_stderr
  end
  result
end
