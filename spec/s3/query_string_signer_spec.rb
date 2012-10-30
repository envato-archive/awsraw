require 'awsraw/s3/query_string_signer'

describe AWSRaw::S3::QueryStringSigner do
  let(:access_key_id)     { "AKIAIOSFODNN7EXAMPLE" }
  let(:secret_access_key) { "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" }

  subject { AWSRaw::S3::QueryStringSigner.new(access_key_id, secret_access_key) }

  context "examples from Amazon docs" do
    it "signs a get request correctly" do
      bucket = "johnsmith"
      object = "photos/puppy.jpg"
      expiry = 1175139620

      p subject.string_to_sign(bucket, object, expiry)
      subject.string_to_sign(bucket, object, expiry).should ==
        "GET\n\n\n#{expiry}\n/johnsmith/photos/puppy.jpg"

      subject.query_string_hash(bucket, object, expiry).should == {
        "AWSAccessKeyId" => access_key_id,
        "Expires"        => expiry.to_s,
        "Signature"      => "NpgCjnDzrM%2BWFzoENXmpNDUsSn8%3D"
      }
    end

  end
end

