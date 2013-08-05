# encoding: utf-8

require 'awsraw/s3/uri_parser'

describe AWSRaw::S3::URIParser do
  context "#path_style?" do
    it "correctly identifies path style URLs" do
      expect(described_class.new("http://s3.amazonaws.com/foo").path_style?).to be_true
      expect(described_class.new("http://foo.s3.amazonaws.com/").path_style?).to be_false
    end
  end

  context "#bucket" do
    it "works for path-style URLs" do
      url = described_class.new("http://s3.amazonaws.com/my-bucket/my-key")
      expect(url.bucket).to eq("my-bucket")
    end

    it "works for hostname-style URLs" do
      url = described_class.new("http://my-bucket.s3.amazonaws.com/my-key")
      expect(url.bucket).to eq("my-bucket")
    end
  end
end
