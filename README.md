# awsraw

A client for [Amazon Web Services](http://www.amazonaws.com/) in the style of
[FlickRaw](http://hanklords.github.com/flickraw/)

## Background

AWSRaw has a simple goal: to let you follow the [AWS REST API
docs](http://docs.aws.amazon.com/AmazonS3/latest/API/APIRest.html), and
translate that into Ruby code with the minimum of fuss.

You use a regular HTTP library to make requests, and AWSRaw provides useful
additions like request signing.

Right now AWSRaw only has direct support for
[Faraday](https://github.com/lostisland/faraday), but you could still use it
with other client libraries with a bit of work.

So far we've only built S3 support. We'd love to see pull requests for other
AWS services.


## Examples

### S3

```ruby
credentials = AWSRaw::Credentials.new(:access_key_id => "...", :secret_access_key => "...")

signer = AWSRaw::S3::FaradayRequestSigner.new(credentials)

connection = Faraday.new do |faraday|
  faraday.response :logger
  faraday.adapter  Faraday.default_adapter
end

connection.get do |request|
  request.url 'http://s3.amazonaws.com/mah-sekret-buckit/reaction.gif'
  signer.sign_request(request)
end
```


## Status

This is still a bit experimental, and is missing some key features, but what's
there is solid and well tested.


## TODO

- Doc on how to signed query-string requests
- Support AWS services other than S3
- Support for Net::HTTP (and other client libraries?)

