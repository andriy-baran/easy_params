# EasyParams

[![Maintainability](https://qlty.sh/gh/andriy-baran/projects/easy_params/maintainability.svg)](https://qlty.sh/gh/andriy-baran/projects/easy_params)
[![Code Coverage](https://qlty.sh/gh/andriy-baran/projects/easy_params/coverage.svg)](https://qlty.sh/gh/andriy-baran/projects/easy_params)
[![Gem Version](https://badge.fury.io/rb/easy_params.svg)](https://badge.fury.io/rb/easy_params)

Provides an easy way to define structure, validation rules, type coercion, and default values for any hash-like structure. It's built on top of `ActiveModel`.

## Types

Available types: `integer`, `decimal`, `float`, `bool`, `string`, `array`, `date`, `datetime`, `time`

### Registering Custom Types

You can register custom types using `EasyParams.register_type`:

```ruby
# Register a weight type that converts between units
EasyParams.register_type :weight do |value|
  case value.to_s.downcase
  when /^(\d+(?:\.\d+)?)\s*kg$/i
    $1.to_f
  when /^(\d+(?:\.\d+)?)\s*lbs?$/i
    $1.to_f * 0.453592  # Convert pounds to kg
  when /^(\d+(?:\.\d+)?)\s*g$/i
    $1.to_f / 1000.0  # Convert grams to kg
  else
    value.to_f
  end
end

# Now you can use the weight type in your params classes
class PersonParams < EasyParams::Base
  weight :mass, presence: true
  weight :target_weight, default: 70.0
  array :weights, of: :weight, default: [65.0, 70.0]
end

# Usage
person = PersonParams.new(mass: '75.5 kg', target_weight: '165 lbs')
# person.mass = 75.5
# person.target_weight ≈ 74.84 (converted from lbs to kg)
```

Custom types work with all EasyParams features including validation, arrays, nested structures, and inheritance.

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

### Schema Extension

You can dynamically extend nested schema definitions using the `#{param_name}_schema` method. This creates a subclass of the original schema that replaces the parent class in the schema, allowing you to add validations, methods, or modify attributes at runtime.

```ruby
class PostParams < EasyParams::Base
  has :post, default: {} do
    integer :id
    string :title
    string :content
    date :published_at, default: Date.today
  end
end

# Extend with additional validations and methods
PostParams.post_schema do
  validates :title, :content, presence: true, if: :published?

  def published?
    published_at.present?
  end
end

# Now the validation will run conditionally
params = PostParams.new(id: 1)
params.valid? # => false (because published_at has default value, so published? returns true)
```

You can also extend collection schemas:

```ruby
class CommentParams < EasyParams::Base
  each :comments, default: [{}, {}] do
    integer :post_id
    string :author
    string :text
  end
end

# Extend with additional attributes and validations
CommentParams.comments_schema do
  string :author, default: 'Anonymous'
  date :created_at, default: Date.today
  validates :post_id, presence: true
end

# Default values are preserved and merged with input
params = CommentParams.new({})
params.comments.size # => 2
params.comments.first.author # => 'Anonymous'
params.comments.first.created_at # => Date.today
```

**Key Features:**
- **Preserves defaults**: Original default values are maintained when extending schemas
- **Runtime flexibility**: Add validations and methods by creating subclasses dynamically
- **Replaces parent**: The new subclass completely replaces the original schema class
- **Collection support**: Works with both `has` (struct) and `each` (collection) parameters

### Composition and Owner Context

EasyParams supports composition through an owner relationship, allowing nested objects to access methods from their parent objects or an external owner object. This is particularly useful for conditional validations and accessing context from nested structures.

Every `EasyParams::Base` instance has an `owner` attribute that is automatically set for nested objects:
- Objects created with `has` get their parent as the owner
- Objects in collections created with `each` get the collection as their owner, and the collection gets the parent as its owner

You can access methods on the owner chain using the `owner_` prefix:

```ruby
class Owner
  def check_name?
    true
  end

  def check_address_city?
    true
  end

  def check_phone_number?
    true
  end
end

class UserParams < EasyParams::Base
  integer :id
  string :name, presence: { if: :owner_check_name? }

  has :address do
    string :street
    string :city, presence: { if: :owner_check_address_city? }
    string :state
    string :zip
  end

  each :phones do
    string :number, presence: { if: :owner_check_phone_number? }
    string :type
  end
end

# Use with an external owner object
owner = Owner.new
params = UserParams.new(
  id: 1,
  address: { street: '123 Main St', city: nil },
  phones: [{ number: nil, type: 'home' }]
)
params.owner = owner

# Validations will use the owner's methods
params.valid? # => false
params.errors[:name] # => ["can't be blank"]
params.address.errors[:city] # => ["can't be blank"]
params.phones[0].errors[:number] # => ["can't be blank"]

# Owner relationships are automatically established
params.owner # => owner
params.address.owner # => params (parent)
params.phones.owner # => params (parent)
params.phones[0].owner # => params.phones (collection)
```

**Key Features:**
- **Automatic owner setup**: Nested objects automatically get their parent as owner
- **Owner chain**: The `owner_` prefix searches up the owner chain to find methods
- **External owners**: Set an external object as owner to provide additional context
- **Conditional validations**: Use owner methods in validation conditions (`if:`, `unless:`)
- **Nested access**: Works at any nesting level - nested objects can access parent methods

### Validation errors

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

Validation messages for nested attributes a set on top level and each nested object has `errors` set.
Errors will look like this.
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
