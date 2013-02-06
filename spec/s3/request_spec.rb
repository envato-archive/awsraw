require 'awsraw/s3/client'

describe AWSRaw::S3::Request do

  let(:access_key)        { 'key' }
  let(:secret_access_key) { 'secret' }
  let(:bucket)            { 'envato.com' }
  let(:key)               { 'index.html' }

  let(:signer)            { AWSRaw::S3::Signer.new(access_key, secret_access_key) }
  let(:params)            { Hash.new }

  subject(:s3_request) { AWSRaw::S3::Request.new(params, signer) }

  before do
    params[:bucket] = bucket
  end

  describe "#host" do

    it "defaults to the standard host" do
      s3_request.host.should == "s3.amazonaws.com"
    end

    it "ignores the region if it is the standard region" do
      params[:region] = 'us-east-1'

      s3_request.host.should == "s3.amazonaws.com"
    end

    it "uses the region specific host when a non standard region is supplied" do
      params[:region] = 'ap-southeast-2'

      s3_request.host.should == "s3-ap-southeast-2.amazonaws.com"
    end
  end

  describe "#path" do

    it "includes the bucket name" do
      s3_request.path.should == "/#{bucket}"
    end

    context "when a key has been supplied" do

      before do
        params[:key] = key
      end

      it "includes the bucket name and key" do
        s3_request.path.should == "/#{bucket}/#{key}"
      end
    end

  end

end
