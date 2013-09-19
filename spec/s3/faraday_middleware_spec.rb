require 'awsraw/s3/faraday_middleware'
require 'ostruct'

describe AWSRaw::S3::FaradayMiddleware do

  let(:credentials) do
    OpenStruct.new(
      :access_key_id     => "AKIAIOSFODNN7EXAMPLE",
      :secret_access_key => "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    )
  end

  let(:app)  { double("app") }
  let(:time) { Time.parse("2013-09-19 19:22:13 +1000") }

  subject { described_class.new(app, credentials) }

  it "signs the request" do
    env = {
      :method       => :put,
      :url          => "http://static.johnsmith.net:8080/db-backup.dat.gz",
      :request_headers => {
        "Date"                         => "Tue, 27 Mar 2007 21:06:08 +0000",
        "Content-Type"                 => "application/x-download",
        "Content-MD5"                  => "4gJE4saaMU4BqNR0kLY+lw==",
        "x-amz-acl"                    => "public-read",
        "X-Amz-Meta-ReviewedBy"        => "joe@johnsmith.net,jane@johnsmith.net",
        "X-Amz-Meta-FileChecksum"      => "0x02661779",
        "X-Amz-Meta-ChecksumAlgorithm" => "crc32"
      }
    }
    subject.call(env)
    expect(env[:request_headers]["Authorization"]).to eq(
      "AWS AKIAIOSFODNN7EXAMPLE:ilyl83RwaSoYIEdixDQcA4OnAnc="
    )
  end

  it "sets the Date header if there isn't one" do
    Time.stub(:now => time) # Freeze time for the duration of the test.

    env = {
      :method          => "GET",
      :url             => "http://s3.amazonaws.com/",
      :request_headers => {}
    }
    subject.call(env)
    expect(env[:request_headers]["Date"]).to eq(time.httpdate)
  end

  it "automatically calculates the MD5 for body content"

  it "blows up if you have a request body, but no content type"

end
