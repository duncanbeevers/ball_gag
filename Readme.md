# BallGag Pluggable User-Content Validation

Validate user-generated content against acceptable content rules.  BallGag provides a convenient interface for describing the acceptability of the attributes of Ruby objects.

When an attribute is gagged, <tt>#{method}_gagged?</tt> and <tt>#{method}_not_gagged?</tt> methods are added to the class.

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
BallGag integrates easily into your Rails app, allowing you validate that <tt>ActiveModel</tt> attributes are acceptable. First, add the gem to your <tt>Gemfile</tt>

````ruby
gem 'ball_gag'
````

Now a <tt>NotGaggedValidator</tt> is available which you can use like this.

````ruby
class Post < ActiveRecord::Base
  include BallGag
  gag(:body) { |body| !/damn/.match body }

  validates :body, :not_gagged => true
end
````

````ruby
Post.new(text: 'That was some damn good watermelon').valid?
# false

Post.new(text: 'That was some fine watermelon').valid?
# true
````

## Engines / Global configuration
Each gagged attribute can be provided its own block to call when checking acceptability, or a global engine can be provided. Set a global engine like this.

````ruby
BallGag.engine = lambda { |content| !/damn/.match content }
````

Any object that responds to <tt>call</tt> can be used as an engine.

## Signature

The first argument to <tt>call</tt> is the value, or hash of values to be checked for acceptability.

If a single attribute is gagged, the <tt>call</tt> method is invoked with the value of the attribute. If multiple attributes are gagged, the <tt>call</tt> method is invoked with a hash whose keys are the gagged attribute names and whose values are the attributes' values.

The second argument to <tt>call</tt> is a hash of options. This hash has the following entries:
<table>
  <tbody>
    <tr>
      <td><tt><strong>:instance</strong></tt></td>
      <td>The instance on which the attribute checked was invoked.</td>
    </tr>
    <tr>
      <td><tt><strong>:options</strong></tt></td>
      <td>The options supplied to the specific <tt>gag</tt> call.</td>
    </tr>
    <tr>
      <td><tt><strong>:single</strong></tt></td>
      <td>A boolean indicating whether the <tt>gag</tt> method was invoked with only one attribute.</td>
    </tr>
    <tr>
      <td><tt><strong>:attr</strong></tt></td>
      <td>The name of the attribute being checked. This is only useful for single-attribute gags.</td>
    </tr>
  </tbody>
</table>

Since options provided to the <tt>gag</tt> method are passed through to your back-end, you can use them when building up a request to send to a 3rd-party.

## Integration with 3rd-party tools
The real power of BallGag is in how it integrates with 3rd-party moderation services. BallGag helps you thread model-specific information through to a remote back-end.

An advanced engine may need to handle accepability of single and multiple attributes. The handler can differentiate between the two types of calls by inspecting the <tt>:single</tt> key of the options it's called with.

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

## License

MIT License
