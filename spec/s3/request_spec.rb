require 'awsraw/s3/client'

describe AWSRaw::S3::Request do

  let(:access_key)        { 'key' }
  let(:secret_access_key) { 'secret' }
  let(:bucket)            { 'envato.com' }
  let(:key)               { 'index.html' }

  let(:signer)            { AWSRaw::S3::Signer.new(access_key, secret_access_key) }
  let(:params)            { Hash.new }

  subject { AWSRaw::S3::Request.new(params, signer) }

  before do
    params[:bucket] = bucket
  end

  describe "#host" do

    it "defaults to the standard host" do
      subject.host.should == "s3.amazonaws.com"
    end

    it "uses the region specific host when a region is supplied" do
      params[:region] = 'ap-southeast-2'

      subject.host.should == "s3-ap-southeast-2.amazonaws.com"
    end
  end

  describe "#path" do

    it "includes the bucket name" do
      subject.path.should == "/#{bucket}"
    end

    context "when a key has been supplied" do

      before do
        params[:key]    = key
      end

      it "includes the bucket name and key" do
        subject.path.should == "/#{bucket}/#{key}"
      end
    end

  end

end

