# SequelCouchbaseModel

This gem is designed for people who are using both the couchbase-model and sequel gems and would like to use sequel model logic
in their couchbase models. This gem is still in beta stage, but right now it has preliminary support for sequel validations and
a few sequel hooks. To use it, your couchbase models must inherit Sequel::Couchbase::Model.

Example:

class VideoWatch < Sequel::Couchbase::Model
  attribute :title
  attribute :a
  attribute :b
  attribute :milliseconds_watched
  attribute :created_at
  attribute :updated_at

  plugin :validation_helpers

  def before_validate
    self.milliseconds_watched ||= 0
  end

  def validate
    validates_presence [:title, :updated_at, :created_at, :milliseconds_watched]
    validates_type String, :title
    validates_type Fixnum, [:a, :b, :milliseconds_watched]
    if a.blank? && b.blank?
      errors.add :base, "At least one of a or b must be filled out!"
    end
  end

  def before_save

  end

  ......
    rest of your logic
  ......
end







## Installation

Add this line to your application's Gemfile:

    gem 'sequel_couchbase_model'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sequel_couchbase_model

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
