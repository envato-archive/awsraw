# awsraw

A client for [Amazon Web Services](http://www.amazonaws.com/) in the style of
[FlickRaw](http://hanklords.github.com/flickraw/)

## Background

AWSRaw has a simple goal: to let you follow the [AWS API
docs](http://aws.amazon.com/documentation/), and translate that into Ruby code
with the minimum of fuss.

This is the opposite of [fog](http://fog.io). AWSRaw tries to add as little
abstraction as possible on top of the AWS REST API.

You use a regular HTTP library to make requests, and AWSRaw provides useful
additions like request signing.

Right now AWSRaw only has direct support for
[Faraday](https://github.com/lostisland/faraday), but you could still use it
with other client libraries with a bit of work.

So far we've only built S3 support. We'd love to see pull requests for other
AWS services.


## Examples

### S3

See the [AWS S3 REST API docs](http://docs.aws.amazon.com/AmazonS3/latest/API/APIRest.html).

```ruby
credentials = AWSRaw::Credentials.new(:access_key_id => "...", :secret_access_key => "...")

connection = Faraday.new("http://s3.amazonaws.com") do |faraday|
  faraday.use      AWSRaw::S3::FaradayMiddleware, credentials
  faraday.response :logger
  faraday.adapter  Faraday.default_adapter
end

response = connection.get("/mah-sekret-buckit/reaction.gif")
```


## Status

This is still a bit experimental, and is missing some key features, but what's
there is solid and well tested.


## TODO

- Support for request content
- Smart handling of errors
    - Identify cases where string-to-sign doesn't match, and display something helpful
    - Raise exceptions for errors?
- Easy was to nicely format XML responses
- Doc on how to sign query-string requests
- Support AWS services other than S3
- Support for Net::HTTP (and other client libraries?)

