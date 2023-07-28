# EasyParams

[![Gem Version](https://badge.fury.io/rb/nina.svg)](https://badge.fury.io/rb/nina)
[![Maintainability](https://api.codeclimate.com/v1/badges/17872804ce576b8b0df2/maintainability)](https://codeclimate.com/github/andriy-baran/easy_params/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/17872804ce576b8b0df2/test_coverage)](https://codeclimate.com/github/andriy-baran/easy_params/test_coverage)

Provides an easy way define structure, validation rules, type coercion and set default values for any hash-like structure. It's built on top of `dry-types`, `dry-structure` and `active_model/validations`.

## Types

Dry types are wrapped by class methods. Avaliable types: `integer`, `decimal`, `float`, `bool`, `string`, `array`, `date`, `datetime`, `time`, `struct`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_params'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install easy_params

## Usage

```ruby
# app/params/api/v2/icqa/move_params.rb
class Api::V1::Carts::MoveParams < EasyParams::Base
  attribute :receive_cart_id, integer
  attribute :i_am_sure, bool
  attribute :location_code, string.default('')
  attribute :sections, struct do
    attribute :from, string
    attribute :to, string
  end
  attribute :options, array.of(struct) do
    attribute :option_type_count, integer
    attribute :option_type_value, integer

    validates :option_type_count, :option_type_value, presence: { message: "can't be blank" }
  end

  validates :receive_cart_id, :location_code, presence: { message: "can't be blank" }
end
```
Validation messages for nested attributes will look like this.
```ruby
{
  :"sections[0].id"=>an_instance_of(Array),
  :"sections[0].post.id"=>an_instance_of(Array),
  :"post.id"=>an_instance_of(Array),
  :"post.sections[0].id"=>an_instance_of(Array)
 }
```
Optionally you can use more compact form
```ruby
class MyParams < EasyParams::Base
  extend EasyParams::DSL

  quantity integer.default(1)
  posts each do
    content string.default('')
  end
  user has do
    role string
  end
end
```
This hovewer has some limitations: for attributes have name like `integer`, `decimal`, `float`, `bool`, `string`, `array`, `date`, `datetime`, `time`, `struct` it won't work as expected.

More examples here [params_spec.rb](https://github.com/andriy-baran/easy_params/blob/master/spec/easy_params_spec.rb)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/easy_params. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/easy_params/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the EasyParams project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/easy_params/blob/master/CODE_OF_CONDUCT.md).
