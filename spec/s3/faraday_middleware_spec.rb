require 'awsraw/s3/faraday_middleware'
require 'ostruct'

describe AWSRaw::S3::FaradayMiddleware do

  let(:credentials) do
    OpenStruct.new(
      :access_key_id     => "AKIAIOSFODNN7EXAMPLE",
      :secret_access_key => "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    )
  end

  let(:app)      { double("app", :call => response) }
  let(:time)     { Time.parse("2013-09-19 19:22:13 +1000") }
  let(:response) { double "response" }

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
    allow(Time).to receive(:now).and_return(time) # Freeze time for the duration of the test.

    env = {
      :method          => :get,
      :url             => "http://s3.amazonaws.com/",
      :request_headers => {}
    }
    subject.call(env)
    expect(env[:request_headers]["Date"]).to eq(time.httpdate)
  end

  it "calculates the Content-MD5 header from the body if there isn't one" do
    env = {
      :method          => :put,
      :url             => "http://s3.amazonaws.com/johnsmith/my-file.txt",
      :body            => "rhubarb",
      :request_headers => {
        "Content-Type" => "text/plain"
      }
    }
    subject.call(env)
    expect(env[:request_headers]["Content-MD5"]).to eq("lBxzvNO0KqwdCwPVMx2IYQ==")
  end

  it "lets you manually set the Content-MD5 header" do
    env = {
      :method          => :put,
      :url             => "http://s3.amazonaws.com/johnsmith/my-file.txt",
      :body            => "rhubarb",
      :request_headers => {
        "Content-Type" => "text/plain",
        "Content-MD5"  => "test-content-md5"
      }
    }
    subject.call(env)
    expect(env[:request_headers]["Content-MD5"]).to eq("test-content-md5")

  end

  it "blows up if you have a request body, but no content type" do
    env = {
      :method          => :put,
      :url             => "http://s3.amazonaws.com/johnsmith/my-file.txt",
      :body            => "rhubarb",
      :request_headers => { }
    }
    expect { subject.call(env) }.to raise_error(AWSRaw::Error, "Can't make a request with a body but no Content-Type header")
  end

  it "does not set the MD5 header if no body is supplied" do
    env = {
      :method          => :get,
      :url             => "http://s3.amazonaws.com/johnsmith/my-file.txt",
      :request_headers => { }
    }
    subject.call(env)
    expect(env[:request_headers].keys).to_not include("Content-MD5")
  end

  it "passes on the call to the app" do
    env = {
      :method          => :get,
      :url             => "http://s3.amazonaws.com/johnsmith/my-file.txt",
      :request_headers => { }
    }

    expect(app).to receive(:call).with(env)

    subject.call(env)
  end
end
