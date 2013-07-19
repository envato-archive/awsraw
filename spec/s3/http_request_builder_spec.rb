require 'awsraw/s3/http_request_builder'

describe AWSRaw::S3::HTTPRequestBuilder do
  subject do
    AWSRaw::S3::HTTPRequestBuilder.new(s3_request)
  end

  let(:content) { "hello world" }
  let(:s3_request) do
    double(
      :uri => URI.parse("http://foo.com/foo"),
      :headers => {"Content-Type" => "application/not-real"},
      :content => content,
      :method => "PUT"
    )
  end

  context "content is a string" do
    let(:content) { "hello world" }
    it "sets the body on the http request to content" do
      subject.build.body.should == content
    end
  end

  context "content is a file object" do
    let(:content) { File.open(__FILE__, "rb") }
    it "sets the body on the http request to content" do
      http_request = subject.build
      http_request.body_stream.should == content
      http_request['Content-Length'].should == File.size(__FILE__).to_s
    end
  end

  it "sets the path on the request" do
    subject.build.path.should == "/foo"
  end

  it "sets the headers" do
    subject.build["Content-Type"].should == "application/not-real"
  end

  it "returns the appropriate request class" do
    subject.build.class.should == Net::HTTP::Put
  end
end
