# AWSRaw

A client for [Amazon Web Services](http://www.amazonaws.com/) in the style of
[FlickRaw](http://hanklords.github.com/flickraw/).

## Background

AWSRaw has a simple goal: to let you follow the [AWS API
docs](http://aws.amazon.com/documentation/), and translate that into Ruby code
with the minimum of fuss.

This is the opposite of [fog](http://fog.io). AWSRaw tries to add as little
abstraction as possible on top of the AWS REST API.

You use a regular HTTP library to make requests, and AWSRaw provides useful
additions like request signing.


## Examples

### Credentials

For all the examples below, you'll need to set up your credentials like this:

```ruby
credentials = AWSRaw::Credentials.new(
  :access_key_id     => "...",
  :secret_access_key => "..."
)
```

### S3

```ruby
connection = Faraday.new("http://s3.amazonaws.com") do |faraday|
  faraday.use      AWSRaw::S3::FaradayMiddleware, credentials
  faraday.response :logger
  faraday.adapter  Faraday.default_adapter
end

response = connection.get("/mah-sekret-buckit/reaction.gif")
```

See the [AWS S3 REST API docs](http://docs.aws.amazon.com/AmazonS3/latest/API/APIRest.html)
for all the requests you can make.


#### Signing query strings

If you need a signed URI with an expiry date, this is how to do it.


```ruby
signer = AWSRaw::S3::QueryStringSigner.new(credentials)

uri = signer.sign(
  "https://s3.amazonaws.com/mah-sekret-buckit/reaction.gif",
  Time.now + 600 # The URI will expire in 10 minutes.
)
```

See the [AWS docs on the subject](http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html#RESTAuthenticationQueryStringAuth).


## Status

This is still a bit experimental, and is missing some key features, but what's
there is solid and well tested.

Right now AWSRaw only has direct support for
[Faraday](https://github.com/lostisland/faraday), but you could still use it
with other client libraries with a bit of work.

So far we've only built S3 support. We'd love to see pull requests for other
AWS services.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## To Do

- Write the missing spec for AWSRaw::S3::FaradayMiddleware
- Add support for request content
- Add smart handling of errors
    - Identify cases where string-to-sign doesn't match, and display something helpful
    - Raise exceptions for errors?
- Add easy ways to nicely format XML responses

