# BallGag Pluggable User-Content Validation

Validate user-generated content against acceptable content rules.  BallGag provides a convenient interface for describing the acceptability of the attributes of Ruby objects.

When an attribute is gagged, `#{method}_gagged?` and `#{method}_not_gagged?` methods are added to the class.

## Example
Here's a simple example demonstrating gagging of a single attribute.

````ruby
class Post
  include BallGag
  attr_accessor :body

  gag(:body) { |body| !/damn/.match body }

  def initialize body
    self.body = body
  end
end
````

````ruby
Post.new('That was some damn good watermelon').body_gagged?
# true

Post.new('That was some fine watermelon').body_gagged?
# false
````

## Using it with Rails
BallGag integrates easily into your Rails app, allowing you validate that `ActiveModel` attributes are acceptable. First, add the gem to your `Gemfile`

````ruby
gem 'ball_gag'
````

Now a `NotGaggedValidator` is available which you can use like this.

````ruby
class Post < ActiveRecord::Base
  include BallGag
  gag(:body) { |body| !/damn/.match body }

  validates :body, :not_gagged => true
end
````

````ruby
Post.new(body: 'That was some damn good watermelon').valid?
# false

Post.new(body: 'That was some fine watermelon').valid?
# true
````

## Engines / Global configuration
Each gagged attribute can be provided its own block to call when checking acceptability, or a global engine can be provided. Set a global engine like this.

````ruby
BallGag.engine = lambda { |content| !/damn/.match content }
````

Any object that responds to `call` can be used as an engine.

Another global option that can be set is `<BallGag.only_validate_on_attribute_changed/tt>. When this is set to true, `:not_gagged` validations will not be run unless the attribute has changed. This can help you avoid writing boilerplate and can make conditionals provided to your validations more concise. Compare the following two examples to see how specifying this option simplifies validations.

````ruby
BallGag.only_validate_on_attribute_changed = true

class Post < ActiveRecord::Base
  validates :text, not_gagged: { unless: -> { author.admin? } }
end
````

vs.

````ruby
class Post < ActiveRecord::Base
  validates :text, not_gagged: { unless: -> { author.admin? || !text_changed? } }
end
````

## Signature

The first argument to `call` is the value, or hash of values to be checked for acceptability.

If a single attribute is gagged, the `call` method is invoked with the value of the attribute. If multiple attributes are gagged, the `call` method is invoked with a hash whose keys are the gagged attribute names and whose values are the attributes' values.

The second argument to `call` is a hash of options. This hash has the following entries:
<table>
  <tbody>
    <tr>
      <td>`<strong>:instance</strong>`</td>
      <td>The instance on which the attribute checked was invoked.</td>
    </tr>
    <tr>
      <td>`<strong>:options</strong>`</td>
      <td>The options supplied to the specific `gag` call.</td>
    </tr>
    <tr>
      <td>`<strong>:single</strong>`</td>
      <td>A boolean indicating whether the `gag` method was invoked with only one attribute.</td>
    </tr>
    <tr>
      <td>`<strong>:attr</strong>`</td>
      <td>The name of the attribute being checked. This is only useful for single-attribute gags.</td>
    </tr>
  </tbody>
</table>

Since options provided to the `gag` method are passed through to your back-end, you can use them when building up a request to send to a 3rd-party.

## Integration with 3rd-party tools
The real power of BallGag is in how it integrates with 3rd-party moderation services. BallGag helps you thread model-specific information through to a remote back-end.

An advanced engine may need to handle accepability of single and multiple attributes. The handler can differentiate between the two types of calls by inspecting the `:single` key of the options it's called with.

Here's an example engine that accepts single and multi-attribute calls and validates against a made-up RESTful moderation service.

````ruby
class ModerationServiceEngine
  include HTTParty
  base_uri MyApp::Application.config.moderation_service_uri

  def self.call fields, options
    if options.delete(:single)
      return call(options[:attr] => fields, options)
    end

    gag_options, instance = options.values_at(:options, :instance)

    sender = gag_options[:sender].bind(instance).call

    response = new(*MyApp::ApplicationConfig.moderation_service_credentials).
      get('/moderate', query: { fields: fields, user: sender })

    response['fields']
  end
end

BallGag.engine = ModerationServiceEngine
````

## Cloaking
If you need flexibility in how the library is used, you can reprogram the API.
First, an alternative top-level module called `BowlingBall` is provided. Include `BowlingBall` in your models to get access to the same functionality you would get with `BallGag`.
You can also specify an alternate verb for gagging attributes, and an alternate preterite form of the verb for querying the attribute. The preterite form supplied also makes positive and negative validations of the same name available.

````ruby
BowlingBall.verb = 'censor'
BowlingBall.preterite = 'censored'

class Post < ActiveRecord::Base
  validates :text, not_censored: true
  censor(:text) { |text| !/damn/.match text }
end
````

You may also indicate that the preterite form of the verb has an inverted meaning.

````ruby
BowlingBall.verb = 'censor'
BowlingBall.negative_preterite = 'acceptable'

class Post < ActiveRecord::Base
  validates :text, acceptable: true
  censor(:text) { |text| !/damn/.match text }
end

Post.new(text: 'That was some damn fine watermelon').text_acceptable?
# false
````

## License

MIT License
