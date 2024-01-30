# EasyParams

[![Gem Version](https://badge.fury.io/rb/nina.svg)](https://badge.fury.io/rb/nina)
[![Maintainability](https://api.codeclimate.com/v1/badges/17872804ce576b8b0df2/maintainability)](https://codeclimate.com/github/andriy-baran/easy_params/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/17872804ce576b8b0df2/test_coverage)](https://codeclimate.com/github/andriy-baran/easy_params/test_coverage)

Provides an easy way define structure, validation rules, type coercion and set default values for any hash-like structure. It's built on top of `active_model`.

## Types

Dry types are wrapped by class methods. Avaliable types: `integer`, `decimal`, `float`, `bool`, `string`, `array`, `date`, `datetime`, `time`

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

To define attribute we have a set of methods which match types list. Ex.
```ruby
integer(param_name, default: nil, normalize: nil, **validations)
```
* `:default` provides a value to return if got `nil` as input or there were errors during coersion.
* `normalize` a proc or lambda that accepts single argument and changes it in some way. It's get called before coercion.
* `validations` mimics `activemodel/validation` can be any supported validation `presence: true, numericality: { only_integer: true, greater_than: 0 }`

In addition we have special option for an `array` type
* `:of` accepts `:integer`, `:decimal`, `:float`, `:bool`, `:string`, `:date`, `:datetime`, `:time` (`:array` is not supported)

There are two special types:

| type              | method to define | default |
|-------------------|------------------|---------|
| :struct           | has              | {}      |
| :array_of_structs | each             | []      |

```ruby
# app/params/api/v2/icqa/move_params.rb
class Api::V1::Carts::MoveParams < EasyParams::Base
  integer :receive_cart_id, presence: { message: "can't be blank" }
  bool :i_am_sure
  string :location_code, default: '', presence: { message: "can't be blank" }
  has :section do
    string :from
    string :to
  end
  array :variant_ids, of: :integer
  each :options do
    integer :option_type_count, presence: { message: "can't be blank" }
    integer :option_type_value, presence: { message: "can't be blank" }
  end
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
