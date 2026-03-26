[![Gem Version](https://badge.fury.io/rb/yourub.svg)](http://badge.fury.io/rb/yourub)


# Yourub
Yourub is a gem for searching YouTube videos using the YouTube Data API v3.

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
  application_name: "yourub"
  application_version: "0.2"
  log_level: WARN

development:
  <<: *yourub_defaults

production:
  <<: *yourub_defaults

test:
  <<: *yourub_defaults
```

If you want to use it from the console, or in another program, you can simply
pass an hash containing the needed options. Change 'yourub' with the name of your application.

```ruby
options = { developer_key: 'mySecretKey',
             application_name: 'yourub',
             application_version: 2.0,
             log_level: 3 }

client = Yourub::Client.new(options)
```


### Examples

`search` always requires a non-empty `:query`. Optional filters narrow results.

Recent sports-related videos in Germany (category is matched by **name**, see below):

```ruby
client = Yourub::Client.new(developer_key: "…", application_name: "yourub", application_version: "1.0")
client.search(query: "highlights", country: "DE", category: "sports", order: "date") do |v|
  puts v
end
```

Search by text only (optional `country` sets `regionCode` on the API request):

```ruby
client = Yourub::Client.new(developer_key: "…", application_name: "yourub", application_version: "1.0")
client.search(query: "aliens") do |v|
  puts v
end
```
that is the content of the response:
```
[{"kind"=>"youtube#video", "etag"=>"\"N5Eg36Gl054SUNiWWc-Su3t5O-k/U6AzLXvcnZt2WFqpnq9_dksV7DA\"", "id"=>"NisCkxU544c", "snippet"=>{"publishedAt"=>"2009-04-05T05:20:10.000Z", "channelId"=>"UCCHcEUksSVKsRDH86j77Ntg", "title"=>"Like A Boss (ft. Seth Rogen) - Uncensored Version", "description"=>"http://www.itunes.com/thelonelyisland\r\n\r\nThe new single from The Lonely Island's debut album \"INCREDIBAD\" In stores now!\r\n\r\nFeaturing Seth Rogen.\r\n\r\nThe Lonely Island is Andy Samberg, Akiva Schaffer & Jorma Taccone.", "thumbnails"=>{"default"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/default.jpg", "width"=>120, "height"=>90}, "medium"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/mqdefault.jpg", "width"=>320, "height"=>180}, "high"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/hqdefault.jpg", "width"=>480, "height"=>360}, "standard"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/sddefault.jpg", "width"=>640, "height"=>480}, "maxres"=>{"url"=>"https://i1.ytimg.com/vi/NisCkxU544c/maxresdefault.jpg", "width"=>1280, "height"=>720}}, "channelTitle"=>"thelonelyisland", "categoryId"=>"23", "liveBroadcastContent"=>"none"}, "statistics"=>{"viewCount"=>"120176425", "likeCount"=>"594592", "dislikeCount"=>"15121", "favoriteCount"=>"0", "commentCount"=>"208109"}}]
```
### Available parameters

`:query` — **Required.** Non-empty string (after stripping whitespace).

`:country` — Optional. One or more [ISO 3166-1 alpha-2](https://www.iso.org/iso-3166-country-codes.html) codes, e.g. `"US"` or `"IT,DE"`. Codes are validated against `Yourub::CountryCodes::ISO_3166_1_ALPHA2` (also exposed as `Yourub::Validator::COUNTRIES` / `client.countries`).

`:category` — Optional. If the name of a category is set, Yourub resolves a category_id from the name: it calls `list_video_categories`, (cached on the client), finds the first item whose title contains your string (case-insensitive). If the name does not match any category, `ArgumentError` lists `id: title` lines of the available categories.

`:count_filter` — Optional hash, e.g. `{ views: ">= 100" }` or `{ views: "== 600" }` (applied after fetching full video resources).

`:max_results` — Optional integer from 1 to 50.

`:order` — Optional. One of: `date`, `rating`, `relevance`, `title`, `videoCount`, `viewCount`. Default `relevance`.
 
### Methods
* `search` — Runs a YouTube search and yields each video hash that passes optional filters. Requires `:query` and typically a block.

```ruby
client = Yourub::Client.new(developer_key: "…", application_name: "yourub", application_version: "1.0")
client.search(query: "space missions") { |v| puts v["id"] }
```

* `get` — Fetches one video’s metadata (`snippet` + `statistics`).

```ruby
client = Yourub::Client.new(developer_key: "…", application_name: "yourub", application_version: "1.0")
client.get("G2b0OIkTraI")
```

* `list_video_categories`

  Calls YouTube [`videoCategories.list`](https://developers.google.com/youtube/v3/docs/videoCategories/list) using only **`regionCode`** (via `region_code:`). The API does not use category IDs in this helper; you pass an [ISO 3166-1 alpha-2](https://www.iso.org/iso-3166-country-codes.html) region when you want that country’s category list.

  `region_code`: Optional. If omitted or blank, the request is sent without `regionCode`, which matches the documented default catalog (United States).

  `hl`: Optional. Sets the `hl` query parameter so snippet titles in the response use the requested locale (e.g. Spanish labels for Spain).

  Caching: Responses are cached per client instance, keyed by `region_code` and `hl`, because category metadata changes rarely. Repeat calls with the same arguments return the same in-memory result without another HTTP request.

  Return value: A `Google::Apis::YoutubeV3::VideoCategoryListResponse` (from `google-apis-youtube_v3`). Use `#items` to iterate categories (each has `#id` and `#snippet`).

```ruby
client = Yourub::Client.new(options)

# Default catalog (documented as US when region is not specified)
us_like = client.list_video_categories

# Explicit region
de_categories = client.list_video_categories(region_code: "DE")

# Region + localized labels
es_labels = client.list_video_categories(region_code: "ES", hl: "es")
```

* `flush_video_categories_cache!`

  Clears all cached `list_video_categories` results for this client. Call this if you need to force a fresh fetch (e.g. after a long-lived process or for tests).

```ruby
client.flush_video_categories_cache!
```


