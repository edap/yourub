[![Code Climate](https://codeclimate.com/github/edap/yourub.png)](https://codeclimate.com/github/edap/yourub)

# Yourub
Yourub is a gem that search videos on youtebe using the YouTube API v3.

## Installation

Add this line to your application's Gemfile:

    gem 'yourub'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yourub

## Usage

Get a developer key as explained [here](http://www.youtube.com/watch?v=Im69kzhpR3I)
After that, you have 2 ways to use the client. If you want to use it in your
rails app,  create a app/config/yourub.yml file as follow:
```
yourub_defaults: &yourub_defaults
  developer_key: 'YoUrDevEl0PerKey'
  youtube_api_service_name: 'youtube'
  youtube_api_version: 'v3'
  application_name: "yourub"
  application_version: "0.1"
  log_level: WARN

development:
  <<: *yourub_defaults

production:
  <<: *yourub_defaults

test:
  <<: *yourub_defaults
```

If you want to use it from the console, or in another program, you can simply
pass an hash containing the needed option
```ruby
options = { developer_key: 'mySecretKey',
             application_name: 'yourub',
             application_version: 2.0,
             log_level: 3 }

client = Yourub::Client.new(options)
```


### Examples

For example, to find the most recent videos in the category "sports" in Germany
```ruby
client = Yourub::Client.new
client.search(country: "DE", category: "sports", order: 'date') do |v|
  puts v
end
```

To find video for a specific thema, use the parameter query

```ruby
client = Yourub::Client.new
client.search(query: "aliens") do |v|
  puts v
end
```
that is the content of the response:
```
[{"kind"=>"youtube#video", "etag"=>"\"N5Eg36Gl054SUNiWWc-Su3t5O-k/U6AzLXvcnZt2WFqpnq9_dksV7DA\"", "id"=>"NisCkxU544c", "snippet"=>{"publishedAt"=>"2009-04-05T05:20:10.000Z", "channelId"=>"UCCHcEUksSVKsRDH86j77Ntg", "title"=>"Like A Boss (ft. Seth Rogen) - Uncensored Version", "description"=>"http://www.itunes.com/thelonelyisland\r\n\r\nThe new single from The Lonely Island's debut album \"INCREDIBAD\" In stores now!\r\n\r\nFeaturing Seth Rogen.\r\n\r\nThe Lonely Island is Andy Samberg, Akiva Schaffer & Jorma Taccone.", "thumbnails"=>{"default"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/default.jpg", "width"=>120, "height"=>90}, "medium"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/mqdefault.jpg", "width"=>320, "height"=>180}, "high"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/hqdefault.jpg", "width"=>480, "height"=>360}, "standard"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/sddefault.jpg", "width"=>640, "height"=>480}, "maxres"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/maxresdefault.jpg", "width"=>1280, "height"=>720}}, "channelTitle"=>"thelonelyisland", "categoryId"=>"23", "liveBroadcastContent"=>"none"}, "statistics"=>{"viewCount"=>"120176425", "likeCount"=>"594592", "dislikeCount"=>"15121", "favoriteCount"=>"0", "commentCount"=>"208109"}}]
```
### Available parameters
`:query` String, example `aliens`

`:country` String, one or more alpha-2 country codes [ISO 3166-1](http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements.htm), example `US` or `IT, DE`. The default one is `US`

`:category` String, example `comedy`. It accept the wildcard `all`, that retrieves videos for all the category for the given nation, or the default one (US) if no one is given

`:count_filter` Hash, example `{views: ">= 100"}` or `{views: "== 600"}`

`:max_results` Integer, between 1 and 50

`:order` String, one of these: 'date', 'rating', 'relevance', 'title', 'videocount', 'viewcount'. The default one is `'relevance'`

It's necessary at least one of this parameters to start a search: `:country`, `:category`, `:query`, `:id`
 
### Methods
* `search`, search youtube videos for the given parameters
```ruby
client = Yourub::Client.new
client.search(id: "NisCkxU544c")
```

* `get_views`
it return the number of views for the given video id
```ruby
client = Yourub::Client.new
client.get_views("G2b0OIkTraI")
```
* `get_video`
retrieves all the metatags available for one video
```ruby
client = Yourub::Client.new
client.get_video("G2b0OIkTraI")
```

##TODO
* Implementing playlist

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Run the test, run the spec/yourub/integration.rb file with a valid developer
   key
5. Push to the branch (`git push origin my-new-feature`)
4. Create new Pull Request
