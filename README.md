[![Code Climate](https://codeclimate.com/github/edap/yourub.png)](https://codeclimate.com/github/edap/yourub)

# Yourub

Yourub is a gem that finds the most recent videos from the Youtube API for the given nation, category and number of views. It's updated to the version 3 of the youtube api

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

    yourub:
      developer_key: 'yourdeveloperkey'
      youtube_api_service_name: 'youtube'
      youtube_api_version: 'v3'
      application_name: "nameofyourapp"
      application_version: "version_number_of_your_app"
      log_level: WARN

As default beahviour, the Yourub gem retrieve 2 videos for each category for the default country, USA.

    result = Yourub::Search.new()
    result.categories
    result.videos


Actually, is possible to select videos for a given country specifying the nation parameter (equivalent to the regionCode on the native youtube API) The parameter value is an [ISO 3166-1](http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements.htm) alpha-2 country code.

    Yourub::Search.new(nation: "IT")


for a given category

    Yourub::Search.new(category: "Sports")


to filter out videos depending on the number of views that they have

    filter = {'views' => ">= 1000"}
    Yourub::Search.new(filter: filter)


to set the max number of videos for each nation/category request (max 50, default 2)

    result = Yourub::Search.new(max_results: 25)

Or all the options together

    filter = {'views' => "<= 200"}
    Yourub::Search.new(nation: "FR", category: "Comedy", max_results: 25, filter: filter)

##TODO

1. filter by search term
2. move nation, category and max result in the filter options
3. adding a CLI

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
