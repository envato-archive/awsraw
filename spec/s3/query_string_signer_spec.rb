require 'awsraw/s3/query_string_signer'
require 'ostruct'

describe AWSRaw::S3::QueryStringSigner do

  let(:credentials) do
    OpenStruct.new(
      :access_key_id     => "AKIAIOSFODNN7EXAMPLE",
      :secret_access_key => "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    )
  end

  subject { described_class.new(credentials) }

  # See the example in the AWS docs:
  # http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html#RESTAuthenticationQueryStringAuth
  it "signs Amazon's example URI correctly" do
    uri = subject.sign("http://johnsmith.s3.amazonaws.com/photos/puppy.jpg", Time.at(1175139620))

    expect(uri.to_s).to eq("http://johnsmith.s3.amazonaws.com/photos/puppy.jpg?AWSAccessKeyId=AKIAIOSFODNN7EXAMPLE&Signature=NpgCjnDzrM%2BWFzoENXmpNDUsSn8%3D&Expires=1175139620")
  end

end
