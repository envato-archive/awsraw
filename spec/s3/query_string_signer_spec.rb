require 'awsraw/s3/query_string_signer'

describe AWSRaw::S3::QueryStringSigner do
  let(:access_key_id)     { "AKIAIOSFODNN7EXAMPLE" }
  let(:secret_access_key) { "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" }

  subject { AWSRaw::S3::QueryStringSigner.new(access_key_id, secret_access_key) }

  context "examples from Amazon docs" do
    it "signs a get request correctly" do
      url = "http://s3.amazonaws.com/johnsmith/photos/puppy.jpg"
      expiry = 1175139620
      headers = {}

      subject.string_to_sign(url, expiry, {}).should ==
        "GET\n\n\n#{expiry}\n/johnsmith/photos/puppy.jpg"

      subject.query_string_hash(url, expiry).should == {
        "AWSAccessKeyId" => access_key_id,
        "Expires"        => expiry.to_s,
        "Signature"      => "NpgCjnDzrM%2BWFzoENXmpNDUsSn8%3D"
      }

      subject.sign_with_query_string(url, expiry).to_s.should ==
        "http://s3.amazonaws.com/johnsmith/photos/puppy.jpg?AWSAccessKeyId=#{access_key_id}&Expires=#{expiry}&Signature=NpgCjnDzrM%2BWFzoENXmpNDUsSn8%3D"
    end

    it "signs a get request to a non-us-east bucket" do
      url = "http://johnsmith.s3.amazonaws.com/photos/puppy.jpg"
      expiry = 1175139620
      headers = {}

      subject.string_to_sign(url, expiry, headers).should ==
        "GET\n\n\n#{expiry}\n/johnsmith/photos/puppy.jpg"

      subject.query_string_hash(url, expiry).should == {
        "AWSAccessKeyId" => access_key_id,
        "Expires"        => expiry.to_s,
        "Signature"      => "NpgCjnDzrM%2BWFzoENXmpNDUsSn8%3D"
      }

      subject.sign_with_query_string(url, expiry).to_s.should ==
        "http://johnsmith.s3.amazonaws.com/photos/puppy.jpg?AWSAccessKeyId=#{access_key_id}&Expires=#{expiry}&Signature=NpgCjnDzrM%2BWFzoENXmpNDUsSn8%3D"
    end
  end

  context "custom headers" do
    let(:url) { "http://s3.amazonaws.com/johnsmith/" }
    let(:expiry) { 1175139620 }

    it "changes the signature based on the Content-MD5 header" do
      subject.string_to_sign(url, expiry, "Content-MD5" => "deadbeef").should ==
        "GET\ndeadbeef\n\n#{expiry}\n/johnsmith/"
    end

    it "changes the signature based on the Content-Type header" do
      subject.string_to_sign(url, expiry, "Content-Type" => "image/png").should ==
        "GET\n\nimage/png\n#{expiry}\n/johnsmith/"
    end

    it "changes the signature based on x-amz-* headers" do
      subject.string_to_sign(url, expiry, "x-amz-acl" => "public-read").should ==
        "GET\n\n\n#{expiry}\nx-amz-acl:public-read\n/johnsmith/"
    end
  end
end

