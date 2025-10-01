# EasyParams

[![Maintainability](https://qlty.sh/gh/andriy-baran/projects/easy_params/maintainability.svg)](https://qlty.sh/gh/andriy-baran/projects/easy_params)
[![Code Coverage](https://qlty.sh/gh/andriy-baran/projects/easy_params/coverage.svg)](https://qlty.sh/gh/andriy-baran/projects/easy_params)
[![Gem Version](https://badge.fury.io/rb/easy_params.svg)](https://badge.fury.io/rb/easy_params)

Provides an easy way to define structure, validation rules, type coercion, and default values for any hash-like structure. It's built on top of `ActiveModel`.

## Types

Available types: `integer`, `decimal`, `float`, `bool`, `string`, `array`, `date`, `datetime`, `time`

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
* `:default` provides a value to return if we get `nil` as input or there were errors during coercion.
* `:normalize` is a Proc or lambda that accepts a single argument and transforms it. It gets called before coercion.
* `validations` mimic ActiveModel validations; can be any supported validation, e.g., `presence: true, numericality: { only_integer: true, greater_than: 0 }`

In addition, there is a special option for the `array` type:
* `:of` accepts `:integer`, `:decimal`, `:float`, `:bool`, `:string`, `:date`, `:datetime`, `:time` (`:array` is not supported)

There are two special types:

| type              | method to define | default |
|-------------------|------------------|---------|
| :struct           | has              | nil     |
| :array_of_structs | each             | []      |

### Defaults for nested types

- **has (struct)**: `default:` must be a Hash. When the input is `nil`, the nested struct is instantiated with that hash; otherwise the provided input is used. If no `default:` is given and the input is `nil`, the value will be `nil`.

  ```ruby
  has :shipping_address, default: { country: 'US' } do
    string :country, default: 'US'
    string :city
  end
  ```

- **each (array_of_structs)**: `default:` should be an Array (typically an array of hashes). When the input is `nil`, the collection defaults to an empty array `[]`. If you provide a default array, each element will be coerced into the nested struct.

  ```ruby
  each :items, default: [{ qty: 1 }] do
    integer :qty, default: 1
  end
  ```

- **Override precedence**: Container-level defaults override attribute-level defaults for the same keys. Attribute defaults apply only when the key is absent (or `nil`) in the provided default/input.

  ```ruby
  has :user, default: { role: 'admin' } do
    string :role, default: 'guest'
    string :name, default: 'Anonymous'
  end
  # input: nil => role: 'admin', name: 'Anonymous'

  each :items, default: [{ qty: 2 }, {}] do
    integer :qty, default: 1
  end
  # input: nil => items.map(&:qty) == [2, 1]
  ```

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

Bug reports and pull requests are welcome on GitHub at [github.com/andriy-baran/easy_params](https://github.com/andriy-baran/easy_params). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/andriy-baran/easy_params/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the EasyParams project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/andriy-baran/easy_params/blob/master/CODE_OF_CONDUCT.md).
