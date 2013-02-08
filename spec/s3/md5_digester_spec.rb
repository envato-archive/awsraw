# encoding: utf-8
require 'awsraw/s3/md5_digester'

describe AWSRaw::S3::MD5Digester do

  describe "#digest" do
    it "returns the md5 digest of the string" do
      AWSRaw::S3::MD5Digester.new("hello").digest.should == Digest::MD5.digest("hello")
    end

    it "returns the md5 digest of a file" do
      file = File.open(__FILE__, "rb")
      AWSRaw::S3::MD5Digester.new(file).digest.should == Digest::MD5.file(__FILE__).digest
    end

    it "raises an error on unknown input" do
      expect { AWSRaw::S3::MD5Digester.new(3).digest }.to raise_error("Unable to digest Fixnum")
    end
  end
end

