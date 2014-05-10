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
If you are using rails, create a app/config/yourub.yml file as follow:
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

### Available parameters
`:query` String, example `aliens`

`:id` Sting, a valid youtube video id, example `NisCkxU544c`. If this parameter is set, tha others are ignored

`:country` String, one or more alpha-2 country codes [ISO 3166-1](http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements.htm), example `US` or `IT, DE`

`:category` String, example `comedy`

`:count_filters` Hash, example `{views: ">= 100"}` or `{views: "== 600"}`

`:max_results` Integer, between 1 and 50

`:order` String, one of these: 'date', 'rating', 'relevance', 'title', 'videocount', 'viewcount'. The default one is `'relevance'`

It's necessary at least one of this parameters to start a search: `:country`, `:category`, `:query`, `:id`
 
### Examples

For example, to find the most recent videos in the category "sports" in Germany
```ruby
client = Yourub::Client.new
client.search(country: "DE", category: "sports", order: 'date')
client.videos
```

To find video for a specific thema, use the parameter query

```ruby
client = Yourub::Client.new
client.search(query: "aliens")
client.videos
```

### Extend Info
As default Yourub will give you back few values, example:

```ruby
client = Yourub::Client.new
client.search(id: "mN0Dbj-xHY0")
```
will report id, title, the default thumb, and the url where you can watch the video
```
[{"id"=>"mN0Dbj-xHY0", "title"=>"GoPro: Hiero Day", "thumb"=>"https://i1.ytimg.com/vi/mN0Dbj-xHY0/default.jpg", "url"=>"https://www.youtube.com/watch?v=mN0Dbj-xHY0"}]
```

To have more values back, use the option `extended_info`
```ruby
client = Yourub::Client.new
client.extended_info = true
client.search(id: "NisCkxU544c")
```
It will give you much more information
```
[{"kind"=>"youtube#video", "etag"=>"\"N5Eg36Gl054SUNiWWc-Su3t5O-k/U6AzLXvcnZt2WFqpnq9_dksV7DA\"", "id"=>"NisCkxU544c", "snippet"=>{"publishedAt"=>"2009-04-05T05:20:10.000Z", "channelId"=>"UCCHcEUksSVKsRDH86j77Ntg", "title"=>"Like A Boss (ft. Seth Rogen) - Uncensored Version", "description"=>"http://www.itunes.com/thelonelyisland\r\n\r\nThe new single from The Lonely Island's debut album \"INCREDIBAD\" In stores now!\r\n\r\nFeaturing Seth Rogen.\r\n\r\nThe Lonely Island is Andy Samberg, Akiva Schaffer & Jorma Taccone.", "thumbnails"=>{"default"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/default.jpg", "width"=>120, "height"=>90}, "medium"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/mqdefault.jpg", "width"=>320, "height"=>180}, "high"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/hqdefault.jpg", "width"=>480, "height"=>360}, "standard"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/sddefault.jpg", "width"=>640, "height"=>480}, "maxres"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/maxresdefault.jpg", "width"=>1280, "height"=>720}}, "channelTitle"=>"thelonelyisland", "categoryId"=>"23", "liveBroadcastContent"=>"none"}, "statistics"=>{"viewCount"=>"120176425", "likeCount"=>"594592", "dislikeCount"=>"15121", "favoriteCount"=>"0", "commentCount"=>"208109"}}]
```

##TODO

1. adding a CLI

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
