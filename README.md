# awsraw

A client for [Amazon Web Services](http://www.amazonaws.com/) in the style of
[FlickRaw](http://hanklords.github.com/flickraw/)

## Background

AWSRaw helps you make authenticated requests to AWS's various services. It
doesn't provide any higher-level concepts like, for example, "delete this
file from S3". Instead, you should understand S3's http API and know that
sending a `DELETE` request to the bucket/key URL will result in the file
being deleted.

While these higher-level concepts can be useful (see, e.g.,
[fog](https://github.com/fog/fog)), they can also get in the way. Being
able to use a new AWS feature by simply following the AWS docs' examples
directly is very nice, instead of having to dig deep into a higher-level
library to figure out how they've mapped that new feature into their
terminology and API.

## Usage

### S3

Standard requests:

```ruby
require 'awsraw/s3/client'

s3 = AWSRaw::S3::Client.new(
       ENV['AWS_ACCESS_KEY_ID'],
       ENV['AWS_SECRET_ACCESS_KEY'])

s3.request(:method  => "PUT",
           :bucket  => "mah-sekret-buckit",
           :key     => "reaction.gif",
           :content => File.read("reaction.gif"),
           :headers => { "Content-Type" => "image/gif" })
```

Signed query-string requests, to allow authorized clients to get protected
resources:

```ruby
require 'awsraw/s3/query_string_signer'

signer = AWSRaw::S3::QueryStringSigner.new(
           ENV['AWS_ACCESS_KEY_ID'],
           ENV['AWS_SECRET_ACCESS_KEY'])

url = "http://s3.amazonaws.com/mah-sekret-bucket/reaction.gif"
expiry = Time.now.utc + 60 # 1 minute from now
temporary_url = signer.sign_with_query_string(url, expiry.to_i)
puts temporary_url
  # => "http://s3.amazonaws.com/mah-sekret-bucket/reaction.gif?Signature=..."
```
