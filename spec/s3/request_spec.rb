require 'awsraw/s3/client'

describe AWSRaw::S3::Request do
  let(:signer) { double(:signature => "signature") }

  describe "#host" do
    it "defaults to the standard host" do
      request = described_class.new({}, signer)
      request.host.should == "s3.amazonaws.com"
    end

    it "ignores the region if it is the standard region" do
      request = described_class.new({ :region => "us-east-1" }, signer)
      request.host.should == "s3.amazonaws.com"
    end

    it "uses the region specific host when a non standard region is supplied" do
      request = described_class.new({ :region => "ap-southeast-2" }, signer)
      request.host.should == "s3-ap-southeast-2.amazonaws.com"
    end
  end

end
