require 'awsraw/s3/client'

describe AWSRaw::S3::Client do

  subject { AWSRaw::S3::Client.new("dummy_access_key_id", "dummy_secret_access_key") }

  context "#request!" do
    it "returns if the response indicates success" do
      response = stub(:failure? => false)
      subject.stub(:request => response)

      expect {
        subject.request!(:method => "PUT")
      }.should_not raise_error
    end

    it "raises an error if the response indicates failure" do
      response = stub(:failure? => true)
      subject.stub(:request => response)

      expect {
        subject.request!(:method => "PUT")
      }.should raise_error("Uh oh! Failure from S3.")
    end
  end

end

