[![Code Climate](https://codeclimate.com/github/dkarter/RelateIQClient/badges/gpa.svg)](https://codeclimate.com/github/dkarter/RelateIQClient) [![Test Coverage](https://codeclimate.com/github/dkarter/RelateIQClient/badges/coverage.svg)](https://codeclimate.com/github/dkarter/RelateIQClient/coverage) ![Travis CI](https://travis-ci.org/dkarter/RelateIQClient.svg?branch=master)

# RelateIQ Client

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'relateiq'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install relateiq

## Usage

### Configuration

To use this gem you must generate an API access token from the RelateIQ settings
screen and allow it access to the lists you want to work with. Once you have
your API credentials, you can configure them like so:

```ruby
RelateIq.configure do |config|
  config.baseurl  = 'https://api.relateiq.com/v2' # (default)
  config.username = 'xxx'
  config.password = 'xxx'
end
```

### Lists

#### Find a list by title

```ruby
RelateIq::List.find_by_title('leads')
```

*Note:* case insensitive


#### Find a list by id

```ruby
RelateIq::List.find('xxxYYYaaaa')
```

#### Get all lists

```ruby
RelateIq::List.all
```

*Note:* this gets stored in cache every time it is called (or when any find
command is called) to clear the cache use the following

```ruby
RelateIq::List.clean_cache
```

#### Find all list items for a contact

```ruby
list = RelateIq::List.find_by_title('leads')
list.items_by_contact_id('somecontactid')
```

#### Upsert Item

```ruby
list = RelateIq::List.find_by_title('leads')
list_item_hash = {
  name: 'Carl Sagan',
  field_values: {
    'website': 'https://cosmos.com',
    'title':   'Astronomer, science educator'
  }
}
list.upsert_item(list_item_hash)
```

*Note:* this is where the magic happens with this gem: using the list information
pulled from the List.all endpoint that we cached before we can now automatically
map field names to values - this is all done for you behind the scenes so you
can avoid storing ids for fields.

Another great benefit for this approach is that it allows you to have a staging
list that you can use to test integration and build out new features.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then,
run `rspec spec` to run the tests. You can also run `bundle console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, first build it using `gem build
relateiq.gemspec`. When the gem is built you can install it directly using `gem
install ./relateiq-0.1.0.gem`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/dkarter/RelateIQClient.

All pull requests are expected to have specs and be well tested.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

