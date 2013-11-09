# AWSRaw

A client for [Amazon Web Services](http://www.amazonaws.com/) inspired by
[FlickRaw](http://hanklords.github.com/flickraw/).


## Background

AWSRaw has a simple goal: to let you follow the [AWS API
docs](http://aws.amazon.com/documentation/), and translate that into Ruby code
with the minimum of fuss. It adds as little abstraction as possible on top of
the AWS REST API. (Think of it as the opposite of [fog](http://fog.io).)

You use a regular HTTP library
([Faraday](https://github.com/lostisland/faraday)) to make requests, and AWSRaw
provides useful additions like request signing.


## Status

This is a pre-release of 1.0, so to install it as a gem you'll need to use `gem
install --pre awsraw`, or declare it as `gem 'awsraw', '~>1.0.0.alpha'` in your
`Gemfile`.

1.0 has solid tests, but has only had light use so far, and feedback is
definitely welcome.

So far we've only built S3 support. We'd love to see pull requests for other
AWS services.

The old, 0.1 version lives on the
[0.1-maintenance](https://github.com/envato/awsraw/tree/0.1-maintenance)
branch.


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

Set up your Faraday connection something like this:

```ruby
connection = Faraday.new("http://s3.amazonaws.com") do |faraday|
  faraday.use      AWSRaw::S3::FaradayMiddleware, credentials
  faraday.response :logger
  faraday.adapter  Faraday.default_adapter
end
```

A simple GET request:

```ruby
response = connection.get("/mah-sekret-buckit/reaction.gif")
```

A PUT request:

```ruby
connection.put do |request|
  request.url "/mah-sekret-buckit/reaction.gif"
  request.headers["Content-Type"] = "image/gif"
  request.body = File.new("reaction.gif")
end
```

See the [AWS S3 REST API docs](http://docs.aws.amazon.com/AmazonS3/latest/API/APIRest.html)
for all the requests you can make.


#### On request bodies

If your request has a body and you don't provide a `Content-MD5` header for it,
AWSRaw will try to calculate one. (The S3 API requires the `Content-MD5` header
for correct request signing.)

It can handle the body behaving as either a `String` or a `File`. If you want
to do something different with the body, you'll need to set the `Content-MD5`
header yourself.

You must also provide a `Content-Type` header for your request if there's a
request body. AWSRaw will raise an exception if you don't.


#### Signing query strings

If you need a signed URI with an expiry date, this is how to do it. See the
[AWS docs on the
subject](http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html#RESTAuthenticationQueryStringAuth).


```ruby
signer = AWSRaw::S3::QueryStringSigner.new(credentials)

uri = signer.sign(
  "https://s3.amazonaws.com/mah-sekret-buckit/reaction.gif",
  Time.now + 600 # The URI will expire in 10 minutes.
)
```


#### HTML Form Uploads

You can use AWSRaw to generate signatures for browser-based uploads. See the
[AWS docs on the
topic](http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingHTTPPOST.html).

```ruby
policy = [
  { "bucket" => "mah-secret-buckit" }
]

policy_json = JSON.generate(policy)

http_post_variables = {
  "AWSAccessKeyID" => credentials.access_key_id,
  "key"            => "reaction.gif",
  "policy"         => AWSRaw::S3::Signature.encode_form_policy(policy_json),
  "signature"      => AWSRaw::S3::Signature.form_signature(policy_json, credentials)
}
```

Then get your browser to do an XHR request using the http_post_variables, and
Bob's your aunty.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## To Do

- Add smart handling of errors
    - Identify cases where string-to-sign doesn't match, and display something helpful
    - Raise exceptions for errors?
- Add easy ways to nicely format XML responses

