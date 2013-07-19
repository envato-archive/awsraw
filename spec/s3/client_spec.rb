require 'awsraw/s3/client'

describe AWSRaw::S3::Client do

  subject { AWSRaw::S3::Client.new("dummy_access_key_id", "dummy_secret_access_key") }

  describe "#request!" do
    it "returns if the response indicates success" do
      response = double(:failure? => false)
      subject.stub(:request => response)

      expect {
        subject.request!(:method => "PUT")
      }.to_not raise_error
    end

    it "raises an error if the response indicates failure" do
      response = double(:failure? => true)
      subject.stub(:request => response)

      expect {
        subject.request!(:method => "PUT")
      }.to raise_error(::AWSRaw::S3::ConnectionError)
    end
  end
end

